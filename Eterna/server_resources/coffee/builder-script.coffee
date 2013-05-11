class @BuilderScriptListsPage extends Builder
   on_build : (block, $container, params) ->
     skip = params['skip']
     size = params['size']
     search = params['search']
     sort = params['sort']
     
     if !(sort?)
       sort = "date"
     
     params.sort = sort  
     param_string = {}
     param_string.sort = "date"
     params['date_sort_url'] = "/web/script/?" + Utils.generate_parameter_string(param_string)
     param_string.sort = "success_rate"
     params['success_rate_sort_url'] = "/web/script/?" + Utils.generate_parameter_string(param_string)
     
     if !(skip?)
       skip = 0
     if !(size?)
       size = 10
     ThemeCompiler.compile_block(block,params,$container)
     
     if $search = @get_element("search")
      $search.attr("value", search)
      $search.keyup((e) =>
        if e.keyCode == KeyCode.KEYCODE_ENTER
          search = $search.attr("value")
          param_string.search = search
          url = "/web/script/?" + Utils.generate_parameter_string(param_string)
          Utils.redirect_to(url)
      )  
      
     #initialize lists of script
     if $script_lists_container = @get_element("script_lists")
       Script.get_script_lists_with_sort(skip,size, null,sort,search,(data) =>
         block = Blocks("script-lists")
         @set_script_lists(block, $script_lists_container, data['lists'])
         @set_pager($script_lists_container, skip, size, (pageindex) =>
            url_params = {skip:pageindex * size, size:size, search:search, sort:sort}
            if search?
              url_params['search'] = search
            return "/web/script/?" + Utils.generate_parameter_string(url_params, true)
           , data)
       )
     
     if $sendfeedback = @get_element("sendfeedback")
       $sendfeedback.click(()->
         window.open("https://getsatisfaction.com/eternagame/topics/scripting_interface_feedback?rfm=1")
         )  
   
   set_pager : ($container, skip, size, callback, data) ->
     if $pager = @get_element("pager")
       total_script = data['total_script']
       pager_str = EternaUtils.get_pager(Math.floor(skip /size), Math.ceil(total_script/size), (pageindex) =>
         return callback(pageindex)
       )
       $pager.html(pager_str)
       
   set_script_lists : (block, $container, lists) ->
     script_params = []
     for i in [0..lists.length-1] by 1
       script = lists[i]
       script_param = {}
       nid = script['nid']
       script_param['id'] = nid
       script_param['title'] = script['title']
       script_param['name'] = script['author']['name']
       script_param['uid'] = script['author']['uid']
       script_param['body'] = script['body']
       script_param['created'] = script['created']
       script_param['commentcounts'] = script['commentcounts']
       script_param['success_rate'] = script['success_rate']
       script_param['type'] = script['type']
       if !(script_param['success_rate']?) || isNaN(script_param['success_rate'])
         script_param['success_rate'] = "0.00"
       else 
         script_param['success_rate'] = new Number(script_param['success_rate']*100).toFixed(2)
       script_param['tested_time'] = script['tested_time']
       if !(script_param['tested_time']?)
         script_param['tested_time'] = "Please wait for test results"
       block.add_block($container, script_param)

class @BuilderScriptPage extends Builder
  on_build : (block, $container, params) ->
    #params['comments'] = []
    params['readonly'] = false
    #initialize if show codes
    if params['nid'] || params['id']
      if params['nid'] then id = params['nid'] else id = params['id']
      Script.increase_pageview(id, (data) ->
        )
        
      Script.get_script(id, (data) =>
        script = data['script'][0]
        params['script'] = script
        if params['nid']
          params['comments'] = data['comments']
          @build_script_show(block, $container, params)
        else
          @build_script_create(block, $container, params)

        #initialize test tutorials button
#        if $test_tutorials = @get_element("test_tutorials")
#          $test_tutorials.click(()=>
#            Overlay.set_loading("replying..")
#            Overlay.show()
#            input = @get_inputs()
#            source = @get_source()
#            if input && input[0] 
#              name = input[0]['value']
#            @test_scripts(name, undefined, source, (test)=>
#              if $test_result = @get_element("test-result")
#                Overlay.hide()
#                $test_result.html('')
#                @load_test_result(test)
#            , (error)=>
#              alert "Evaluation server is not available now."
#              Overlay.hide()
#            )
#          )  
      )
    else
      @build_script_create(block, $container, params)  
    
  build_script_create : (block, $container, params) ->
    ThemeCompiler.compile_block(block,params,$container)
    @initialize_editor(params['readonly'])
    if params['id']
      @put_script(params['script'], true, false)
    @initialize_flash()
    @initialize_pervasives()
    @initialize_evaluate()
            
    #initialize save button
    if $save_script = @get_element("submit-script")
      $save_script.click(() =>
        if Application.CURRENT_USER
          @save_script()
        else
          alert "Please log in to submit script"
      )
    
    #initialize add input button
    if $add_input = @get_element("add-input")
      if $input_containers = @get_element("input-containers")
        block = Blocks("input-container")
        input_count = 0
        $add_input.click(()=>
          block.add_block($input_containers, {num:input_count, create:true})
          input_count++
        )       
  build_script_show : (block, $container, params) ->
    ThemeCompiler.compile_block(block,params,$container)
    if params['nid']
      params['readonly'] = true
      @initialize_editor(params['readonly'])
      @put_script(params['script'], true, true)
    @initialize_flash()
    @initialize_pervasives()
    @initialize_evaluate()

    #initialize start button
    if $start_from_copy = @get_element("start-from-copy")
      $start_from_copy.click(() =>
        url_params = {id:params['nid']}
        url = "/web/script/create/?" + Utils.generate_parameter_string(url_params)
        Utils.redirect_to(url)
      )
      
  load_script : (id, code, input) ->
    Script.get_script(id, (data) =>
      script = data['script'][0]
      @put_script(script, code, input)
    ) 
 
  put_script : (script, code, input) ->
    if code
      @editor.setValue(script['source'])
      $title = @get_element("title")
      $title.html(script['title'])
        
      author = script['author']
      if $author = @get_element("author")
        $author.html(author['name'])
        $author.click(()=>
          url = "/web/player/"+author['uid']+"/"
          Utils.redirect_to(url)
          )

    if input
      if script['input'] != null
        try
          input_scripts = JSON.parse(script['input'])
        catch Error
          input_scripts = [{name:"name0", value:script['input']}]
        if $input_containers = @get_element("input-containers")
          block = Blocks("input-container")
          if input_scripts.length > 0
            for i in [0..input_scripts.length-1]
              input_script = input_scripts[i]
              name = input_script['name']
              value = input_script['value']
              block.add_block($input_containers, {name:name, value:value})
        
    @load_test_result(script['test'])
    
    if $description = @get_element("description-info")
      if description = script['body']
        $description.html(description)
    
    if $tested_time = @get_element("tested-time")
      if !(script['tested_time']?)
        $tested_time.html("Please wait for test results")
      else
        $tested_time.html(script['tested_time'])
    
    if $type = @get_element("type-info")
      if type = script['type']
        $type.html(type)
      else
        $type.html("Etc")
      if type != "Puzzle solving"
          if $see_results = @get_element("see-results")
            $see_results.hide()
        
    if $pageview = @get_element("pageview-info")
      if pageview = script['pageview']
        $pageview.html(pageview)
      else
        $pageview.html("0")

  load_test_result : (test_result) ->
    if $test_result = @get_element("test-result")
      if tests = test_result
        block = Blocks("block-test-result")
        for i in [0..tests.length-1]
          test = tests[i]
          test_param = {}
          test_param['puzzle_nid'] = test['nid']
          test_param['puzzle_title'] = test['name']
          test_param['num_cleared'] = test['num_cleared']
          test_param['test_result'] = test['result']
          test_param['test_cause'] = if test['cause'].length > 25 then test['cause'].substring(0,25) + "..." else test['cause']
          test_param['test_time'] = test['eval_time'] / 1000
          block.add_block($test_result, test_param)    

  save_script : () ->
    if $title = @get_element("title")
      if $title.attr('value') == "" 
        alert "You have to write the title!!"
        return
    
    if $description = @get_element("description")
      if $description.attr('value') == ""
        alert " You have to write the description!!"
        return    

    Overlay.set_loading("replying..")
    Overlay.show()
      
    title = $title.attr('value')
    description = $description.attr('value')
    type = $('#script_type option:selected').val()
    input = @get_inputs()

    source = @editor.getValue()

#    Script.post_script(title, source, type, input, {}, description, (data) =>
#      if !data['success'] || data['nid'] == null || data['nid'] == undefined
#        alert "Submit fail. Try again please!!"
#        return
#      else
#        Utils.redirect_to("/web/script/"+data['nid']+"/")
#      Overlay.hide()
#    )
    # test script
    if input && input[0] 
      name = input[0]['value']
    
    Script.post_script(title, source, type, input, null, description, (data) ->
      if !data['success'] || data['nid'] == null || data['nid'] == undefined
        alert "Submit fail. Try again please!!"
      Utils.redirect_to("/web/script/"+data['nid']+"/")
      Overlay.hide()
      )          

  get_tutorial_infos : () ->
    tutorial_infos = new Array()
    tutorial_infos.push({puzzle:{id:"13450", title:"Tutorial 6 : Final!", secstruct:"(((((...((((...(((....)))...))))...)))))"}})
    tutorial_infos.push({puzzle:{id:"496828", title:"Tutorial 5 : More Loops!", secstruct:".(.(....).)."}})
    tutorial_infos.push({puzzle:{id:"13405", title:"Tutorial 4 : Stacks and Loops!", secstruct:"((((....))))"}})
    tutorial_infos.push({puzzle:{id:"13449", title:"Tutorial 3 : Stacks!", secstruct:"((((....))))"}})
    tutorial_infos.push({puzzle:{id:"13399", title:"Tutorial 2 : Pairs!", secstruct:"((((....))))"}})
    tutorial_infos.push({puzzle:{id:"13375", title:"Tutorial 1 : Basics!", secstruct:"...."}})
    
# To automatically get tutorial infos
#    PageData.get_tutorials((data)->
#      tutorials = data['puzzles']
#      tutorial_infos = new Array()
#      get_puzzle = (id) =>
#        PageData.get_puzzle(id, (data) =>
#          tutorial_infos.push(data)
#          if tutorials.length > 0
#            get_puzzle((tutorials.pop())['id'])
#          else success_cb(tutorial_infos)    
#        , (data) ->
#          alert "Get puzzle information fail!!!, please try again"
#        )
#      get_puzzle((tutorials.pop())['id'])
#    )
    return tutorial_infos

  test_scripts : (input, target_info, source, success_cb, fail_cb) ->    
    test = new Array()
    Script.evaluate_script(input, target_info, source, (data)=>
      test_targets = data['data']
      for i in [0..test_targets.length-1] by 1
        test_target = test_targets[i]
        test_result = {}
        test_result['nid'] = test_target['nid']
        test_result['name'] = test_target['name']
        test_result['result'] = test_target['result']
        test_result['cause'] = test_target['cause']
        test_result['eval_time'] = test_target['eval_time']
        test_result['num_cleared'] = test_target['num_cleared']
        test.push(test_result)
        
      success_cb(test)  
    , fail_cb)


#    test_targets = target_info
#    test = new Array()
#    for i in [0..test_targets.length-1] by 1
#      target = test_targets[i]['puzzle']
#      id = target['id']
#      puzzle_sequence = target['secstruct']
#      puzzle_name = target['title']
#      name = input
      
#      if name && name != ""
#        param = "var "+name+"='"+puzzle_sequence+"';"
#      else param = ""
#      code = param+source
#
#      eval_data = Script.evaluate_script_code_sync(code)
#      eval_data = eval_data['data']
      
#      test_result = {}
#      test_result['nid'] = id
#      test_result['name'] = puzzle_name
#      if eval_data['result'] then test_result['result'] = eval_data['result']
#      if eval_data['cause'] then test_result['cause'] = eval_data['cause']
#      test_result['eval_time'] = eval_data['eval_time']
#      test.push(test_result)
#    success_cb(test)    
              
  initialize_editor : (readonly) ->
    #initialize editor
    $code = @get_element("code")
    if $code
      @editor = CodeMirror.fromTextArea($code.get(0), {
        lineNumbers:true,
        matchBrackets:true,
        extraKeys:{"Enter": "newlineAndIndentContinueComment"},
        readOnly:readonly
        })     
      if readonly 
        wrapper = @editor.getWrapperElement()
        $(wrapper).css('background-color','#BDBDBD')    
 
  initialize_flash : () ->
    #initialize flash
    flashvars = {}
    flash_params =  {allowScriptAccesss: "always"}
    attributes = {id: "viennalib"};
    swfobject.embedSWF("/eterna_resources/scriptfold.swf", "viennalib", "0", "0", "9.0.0", false, flashvars, flash_params, attributes);
    
 
  initialize_pervasives : () ->
    #initialize default methods with reflection
    window.clear = @clear
    window.out = @out
    window.outln = @outln

  initialize_evaluate : () ->
    $input = @get_element("input")
    $code = @get_element("code") 
    if $evaluation = @get_element("evaluation")
      $evaluation.click(()=>
        @clear()
        @on_evaluate()
      )      
    
    if $documentation = @get_element("documentation")
      $documentation.click(()->
        window.open("/web/script/documentation/functions/")
        )
        
  out : (result) ->
    if @get_element
      if $result = @get_element("result")
        value = $result.attr('value')
        $result.attr('value', value + result)
    else
      $result = $('#result')
      value = $result.attr('value')
      $result.attr('value', value + result)
    
  outln : (result) ->
    @out result
    @out "\n"  
      
  clear : () ->
    if @get_element
      if $result = @get_element("result")
        $result.attr('value', "")
    else
      $result = $('#result')
      $result.attr('value', "")
       
  on_evaluate : () ->
    input_array = @get_inputs()
    param = ""
    if input_array.length > 0
      for i in [0..input_array.length-1]
        $name = @get_element(input_array[i]['name'])
        value = input_array[i]['name']+"-value"
        $value = @get_element(value)
        v = $value.attr('value').replace(/\n/gi, '\\n')
        param += " var " + $name.attr('value') + "='" + v + "';"
    code = @editor.getValue()
    
    #default timeout 10sec
    timeout_sec = 10
    if $timeout_sec = @get_element("timeout")
      value = $timeout_sec.attr('value')
      if value != "" then timeout_sec = value
    code = @insert_timeout(code, timeout_sec)
    
    if @isWebWorkerSupport()
      timeout = false
      tick = 1000
      
      worker = new Worker "/workbranch_kws/frontend/jscripts/eterna/script-library.js"
      worker.onmessage = (event) =>
        data = event.data
        if data && data.cmd
          evaluation = data.cmd+"('"+data.arg+"')"
          @evaluate(evaluation)
        else
          @outln(data)
          timeout = true
        return
        
      @resetTimeValue()  
      time = new Date() 
      timer = () =>
        _time = new Date()
        _time.setTime(_time.getTime() - time.getTime())
        hour = _time.getHours()
        min = _time.getMinutes()
        sec = _time.getSeconds()
        @setTimeValue(hour,min,sec) 
        if !timeout
          setTimeout(timer, tick)
        else return
      setTimeout(timer,tick)
      
      funcs = eval("var funcs='';for(var method in this) funcs+='function '+method+'(_arg){postMessage({cmd:\"'+method+'\",arg:_arg});};'; funcs;")
      statement = "function lambda(){"+param+code+"};lambda();"
      param = funcs + statement
      worker.postMessage(param)
    else
      try
        @outln(@evaluate(param+code))
      catch Error
        @outln(Error)  

  insert_timeout : (source, timeout) ->
    inserted_code = "if((new Date()).getTime() - global_timer.getTime() > " + timeout * 1000 + ") {outln(\""+timeout+"sec timeout\");return;};"
    #regexp = /while\s*\(.*\)\s\{?|for\s*\(.*\)\s\{?/
    regexp = /while\s*\([^\)]*\)\s*\{?|for\s*\([^\)]*\)\s*\{?/
    code = "var global_timer = new Date(); "
    while(source.search(regexp) != -1)
       chunk = source.match(regexp)[0]
       index = source.indexOf(chunk) + chunk.length
       
       # if while or for with no {}
       if(chunk.charAt(chunk.length-1)) != "{"
         nextRegexp = /.*[\(.*\)|[^;]|\n]*;{0,1}/
         # get nextline(until find ;)
         nextline = source.substring(index)
         nextline = nextline.match(nextRegexp)[0]
         code += source.substring(0, index) + "{" + inserted_code + nextline + "}"
         index += nextline.length
       else 
       # if while or for with bracket 
         code += source.substring(0, index) + inserted_code
       if(source.length > index) then source = source.substring(index)
       else
         source = ""
         break
    code += source
    return code   
        
  evaluate : (source) ->
    Lib = new Library
    statement = "function lambda(){"+source+"};"
    result = eval(statement+"lambda();")
    return "\nReturn value : " + result      
    
          
  isWebWorkerSupport : () ->
    #checked = if $webworker = @get_element("webworker") then $webworker.is(":checked") else true
    #return (typeof(Worker) != "undefined") && checked;
    return false

  resetTimeValue : () ->
    @setTimeValue(0,0,0)
    
  setTimeValue : (hour, min, sec) ->
    if $hour = @get_element("timer-hour") then $hour.html(@format(hour))
    if $min = @get_element("timer-min") then $min.html(@format(min))
    if $sec = @get_element("timer-sec") then $sec.html(@format(sec))

  format : (num) ->
    return if parseInt(num) < 10 then String("0" + num) else String(num) 

  get_inputs : () ->
    if $input_form = @get_element("input-form")
      arr = $input_form.serializeArray()
      if arr.length > 0
        result = new Array
        for i in [0..arr.length-1]
          input = arr[i]
          if input['value'] != ""
            result.push(input)
        return result
    return []

  get_source : () ->
    if @editor
      return @editor.getValue()
    return ""
            
class @BuilderInput extends Builder
  on_build : (block, $container, params) ->
    ThemeCompiler.compile_block(block,params,$container)
    if $delete = @get_element("delete")
      $delete.click(()->
        $container.html("")          
        )

class @BuilderScriptTestResultPage extends Builder
  on_build : (block, $container, params) ->
    @size = 20
    @before_skip = @size
    @after_skip = @size
    ThemeCompiler.compile_block(block,params,$container)
    @generate_testresult(params['nid'], params)
    
    
    if $before_result_more = @get_element("before-result-more")
      $before_result_more.click(() =>
        @request_test_result_before(params['nid'], @before_skip, @size)
        @before_skip += @size
        )
    if $after_result_more = @get_element("after-result-more")
      $after_result_more.click(() =>
        @request_test_result_after(params['nid'], @after_skip, @size)
        @after_skip += @size
        )
 
  show_record : ($container, success, fail) ->
    block = Blocks("block-test-record")
    record = []
    record['total'] = success+fail
    if isNaN(record['total'])
      record['total'] = 0
    record['success'] = success
    if isNaN(record['success'])
      record['success'] = 0
    record['fail'] = fail
    if isNaN(record['fail'])
      record['fail'] = 0
    if record['total'] > 0
      record['rate'] = (record['success'] / record['total'] * 100).toFixed(2)
    else
      record['rate'] = 0
    block.add_block($container, record)  
    
  generate_testresult : (script_nid, params) ->
    $bloading = @get_element("before-loading")
    $bloading.show()
    $aloading = @get_element("after-loading")
    $aloading.show()
   
    Script.get_script_with_test(script_nid, @skip ,@size,(data) =>
      @skip += @size
      script = data['script'][0]
      
      if $tested_time = @get_element("tested-time")
        if !(script['tested_time']?)
          $tested_time.html("Please wait for test results")
        else
          $tested_time.html(script['tested_time'])    
      test = script['test']
      if test
        before = test['before']
        after = test['after']
        if $record = @get_element("record")
          @show_record($record, test['before']['success']+test['after']['success'], test['before']['fail'] + test['after']['fail'])
        if $record_before = @get_element("record-before")
          @show_record($record_before, test['before']['success'], test['before']['fail'])
        if $record_after = @get_element("record-after")
          @show_record($record_after, test['after']['success'], test['after']['fail'])
        @load_test_result(before['test'], after['test'])

      $bloading.hide()
      $aloading.hide()
  
      )
      
  load_test_result : (before, after) ->
    if $test_result_before = @get_element("test-result-before")
      @load_test_result_with_container($test_result_before, before)
    if $test_result_after = @get_element("test-result-after")
      @load_test_result_with_container($test_result_after, after)
  
  request_test_result_before : (nid, skip, size) ->
    $loading = @get_element("before-loading")
    $loading.show()
    Script.get_script_with_test(nid, skip, size, (data)=>
      script = data['script'][0]
      if $test_result_before = @get_element("test-result-before")
        @load_test_result_with_container($test_result_before, script['test']['before']['test'])
      $loading.hide()
      )
  
  request_test_result_after : (nid, skip, size) ->
    $loading = @get_element("after-loading")
    $loading.show()
    Script.get_script_with_test(nid, skip, size, (data)=>
      script = data['script'][0]
      if $test_result_after = @get_element("test-result-after")
        @load_test_result_with_container($test_result_after, script['test']['after']['test'])
      $loading.hide()
      )
  
  load_test_result_with_container : ($container, result) ->
    if $container
      if result.length > 0
        @load_test_result_packer($container, result)
      else
        $container.find('#noresult').show()
     

  load_test_result_packer : ($test_result, testresults) ->
#    packer = Packers($test_result)
    block = Blocks("test-result-block")
    test_result_params = []
    for test in testresults
      test_param = {}
      test_param['puzzle_nid'] = test['nid']
      test_param['puzzle_title'] = test['name']
      test_param['num_cleared'] = test['num_cleared']
      test_param['test_result'] = test['result']
      #test_param['test_cause'] = if test['cause'].length > 25 then test['cause'].substring(0,25) + "..." else test['cause']
      test_param['test_cause'] = test['cause']
      test_param['test_time'] = test['eval_time'] / 1000
      test_result_params.push(test_param)
      block.add_block($test_result, test_param)
      do (test_param) =>
        if $show_sequence = @get_element(test_param['puzzle_nid']+'_show_sequence')
          if $test_cause = @get_element(test_param['puzzle_nid']+'_test_cause')
            $test_cause.hide()
            $show_sequence.click(()=>
              $show_sequence.hide()
              $test_cause.show()
            )
    
#    packer.add(test_result_params)