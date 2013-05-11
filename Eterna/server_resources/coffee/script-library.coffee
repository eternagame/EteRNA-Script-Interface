@onmessage = (event) ->
  try
    data = event.data
    Lib = new Library
    Lib.webworker = true
    result = "Return value : " + (eval data)
  catch Error
    result = Error.message
  postMessage result 

                    
class @Library 
  constructor : () ->
    # default bases sequence
    @bases = 'AGCU'
    @webworker = false 

  # fold
  fold : (seq) ->
    if !@webworker 
      return document.getElementById('viennalib').fold(seq)
    else 
      return postMessage({cmd:"Lib.fold",arg:seq})

  energyOfStruct : (sequence, structure) ->
  	return document.getElementById('viennalib').energyOFStruct(sequence, structure);
  
  # replace character
  # ex) replace("AAAA", 2, "B") = "AABA"  
  replace : (seq, index, to) ->
    if(typeof(seq) == "string")
      return seq.substring(0, index) + to + seq.substring(index+1, seq.length) 
    if(typeof(seq) == "object")
      seq[index] = to
      return seq
  
  # return next sequence by default bases sequence
  # ex) next("AAAA") = "AAAG"
  nextSequence : (seq) ->
    return @nextSequenceWithBases(seq, @bases)
      
  nextSequenceWithBases : (seq, bases) ->
    replace_ = @replace    
    next_ = (seq, index) ->
      if seq[index] == bases[3]
        next_(replace_(seq, index, bases[0]), ++index)
      else
        return replace_(seq, index, bases[bases.indexOf(seq[index]) + 1])    
    return next_(seq,0)

  random : (from, to) ->
    return Math.floor( (Math.random() * (to - from + 1)) + from )
  
  randomSequence : (size) ->
    return @randomSequenceWithBases size, @bases
    
  randomSequenceWithBases : (size, bases) ->
    sequence = ""
    for i in [0..size-1]
      sequence += bases[@random(0, bases.length-1)]
    return sequence

  map : (fn, sequence) ->
    for i in [0..sequence.length-1]
      (fn sequence[i],i)
    
  filter : (fn, sequence) ->
    result = ""
    for i in [0..sequence.length-1]
       if (fn sequence[i]) then result += sequence[i]
    return result
    
  splitDefault : (structure) ->
    result = new Array
    item = structure[0]
    index = 0
    for i in [0..structure.length]
      if item != structure[i] || i == structure.length
        item = structure[i]
        result.push structure.substring(index, i)
        index = i
    return result

  join : (array) ->
    result = ""
    for item in array
      result += item
    return result

  set : (fn, structure) ->
    array = @split structure
    @map (item, index) =>
      (fn array, item, index)
    , array
    return array

  distance : (source, destination) ->
    return @distanceCustom (index) =>
      return if source[index] == destination[index] then 0 else 1 
    , source, destination
    
  distanceCustom : (fn, source, destination) ->
    if source.length == destination.length
      sum = 0
      @map (_, index) =>
        sum += (fn index)
      , source
      return sum
    return -1

  getStructure : (nid) ->
    data = AjaxManager.querySync("GET", Application.GET_URI, {type:"puzzle",nid:nid})
    data = data['data']
    if data && data['puzzle'] && data['puzzle']['secstruct']
      return data['puzzle']['secstruct']  
    else
      throw new RNAException("Puzzle not found!!")
    
        
  getStructureWithAsync : (nid, success_cb) ->
    PageData.get_puzzle(nid, (data)->
      (success_cb data['puzzle']['secstruct'])
      )

  EternaScript : (id) ->
    return eval(@EternaScriptSource(id))

  EternaScriptSource : (id) ->
    data = Script.get_script_sync(id)
    script = data['script'][0]
    code = ""
    
    # for multiple input implementation
    if script['input']
      inputs = JSON.parse(script['input'])
      for i in [0..0]
        input = inputs[i]
        code += "var "+input['value']+"=arguments["+i+"];"
    code = "function _"+id+"(){Lib = new Library();"+code+script['source']+"};_"+id
    return code

class @RNAElement
  @Loop = "loop"
  @Stack = "stack"
  
  @Hairpin = "Hairpin"
  @Bulge = "Bulge"
  @Internal = "Internal"
  @Multiloop = "Multiloop"
  @Dangling = "Dangling"
    
  constructor : (index, _structure) ->
    @parent = null
    @childs = new Array
    @elements = new Array
    @segment_count = 1
    @type = null
    @base_type = null 
    @add(index, _structure)

  add : (_index, _structure) ->
    _pair = undefined
    elements = @getElements()
    if elements.length > 0
      if _structure == "." && Math.abs(elements[elements.length-1]['index']-_index) > 1 
        @setSegmentCount(@getSegmentCount()+1)
      if _structure == ")"
        for i in [elements.length-1..0] by -1
          if elements[i]['pair'] == undefined
            elements[i]['pair'] = _index
            _pair = elements[i]['index']
            break
    @getElements().push({index:_index, structure:_structure, pair:_pair})  
  
  addChild : (node) ->
    node.parent = this
    @childs.push(node)

  getChilds : () ->
    return @childs

  getParent : () ->
    return @parent

  getElements : () ->
    return @elements

  isPaired : () ->
    temp = new Array
    elements = @getElements()
    for i in [0..elements.length-1]
      if elements[i]['structure'] == "(" then temp.push(i)
      else if elements[i]['structure'] == ")" then temp.pop()
      
    return temp.length == 0 
        
  setType : (type) ->
    @type = type
  getType : (type) ->
    return @type  

  setBaseType : (type) ->
    @base_type = type
  getBaseType : () ->
    return @base_type

  getIndices : () ->
    array = new Array
    @map (element, i) ->
      array.push(element['index'])
    , @getElements()
    return array
      
  getStructures : () ->
    array = new Array
    @map (element, i) ->
      array.push(element['structure'])
    , @getElements()
    return array

  isStack : () ->
    return @getBaseType() == RNAElement.Stack
  isLoop : () ->
    return @getBaseType() == RNAElement.Loop

  isHairpin : () ->
    return @getType() == RNAElement.Hairpin
  isBulge : () ->
    return @getType() == RNAElement.Bulge
  isMultiloop : () ->
    return @getType() == RNAElement.Multiloop
  isDangling : () ->
    return @getType() == RNAElement.Dangling
  isInternal : () ->
    return @getType() == RNAElement.Internal

  getSegmentCount : () ->
    return @segment_count

  setSegmentCount : (count) ->
    @segment_count = count

  map : (func, array) ->
    new Library().map(func, array)
  
class @RNA
  constructor : (structure) ->
    @structure = structure
    @pair_map = @getPairmap(structure)
    @root = @parse(0, structure.length-1, structure)
    @parse_type(@root)
          
  getPairmap : (structure) ->
    temp = new Array
    map = new Array
    for i in [0..structure.length-1]
      if structure[i] == "(" then temp.push(i)
      else if structure[i] == ")"
        if temp.length == 0 then throw new RNAException("pair doesn't matched")
        index = temp.pop()
        map[index] = i
        map[i] = index
        
    if temp.length > 0 then throw new RNAException("pair doesn't matched")
    return map
    
  parse : (start, end, structure) ->
    parsedElement = @_parse(start, end, structure)
    root = parsedElement['element']
    if parsedElement['index'] >= structure.length-1 then return root
    else 
      root.addChild(@parse(parsedElement['index'] + 1, end, structure))
      return root 
   
  _parse : (start, end, structure) ->
    c = structure[start]
    e = new RNAElement(start, c)
    e.setBaseType(RNAElement.Loop)
    i = start
    while (i < end)
      i++
      if c == "(" && (structure[i] == "(" || structure[i] == ")")
        if structure[i] == "(" && @pair_map[i] != @pair_map[i-1]-1
          temp = @_parse(@pair_map[i]+1, @pair_map[i]-1, structure)
          temp = temp['element']
          e.addChild(temp)
          temp2 = @_parse(i, @pair_map[i], structure)
          temp2 = temp2['element']
          temp.addChild(temp2)
          i = @pair_map[i-1]-1
        else
          e.add(i, structure[i])
          if e.isPaired() 
            e.setBaseType(RNAElement.Stack)
            return {element:e, index:i}
      else if c == "." && structure[i] == "."
        if structure[i]=="." && structure[i-1]=="."
          e.add(i,structure[i])
        else
          dtest = true
          dangling = new RNAElement(i, c)
          dangling.setBaseType(RNAElement.Loop)
          for dtest_i in [i+1..structure.length-1]
            if structure[dtest_i] != "."
              dtest = false
              break
            dangling.add(dtest_i, structure[dtest_i])
          if dtest
            e.addChild(dangling)
            return {element:e, index:dtest_i}
          else   
            e.add(i,structure[i])
      else if structure[i] == ")" then return {element:e, index:i-1}
      else 
        child = @_parse(i, end, structure)
        e.addChild(child['element'])
        i = child['index']  
    return {element:e, index:i}  

  parse_type : (element) ->
    @map (element) =>
      parent = element.getParent()
      childs = element.getChilds()
      indices = element.getIndices()
      
      if (parent == null || childs.length == 0) && element.isLoop() && (indices[0] == 0 || indices.pop() == @getStructure().length-1) then element.setType(RNAElement.Dangling)
      else if parent && parent.isStack() && childs.length == 1 && childs[0].isStack() 
        if element.getSegmentCount() == 1 then element.setType(RNAElement.Bulge)
        else if element.getSegmentCount() == 2 then element.setType(RNAElement.Internal)
      else if element.getSegmentCount() >= 2 && childs.length >= 2 then element.setType(RNAElement.Multiloop)
      else if parent && parent.isStack() && childs.length == 0 && element.isLoop()
        if element.getStructures().length < 3 then throw new RNAException("Hairpin length is under 3") 
        element.setType(RNAElement.Hairpin)
      
  getStructure : () ->
    return @structure                   

  getRootElement : () ->
    return @root

  map : (func) ->
    _map = (element) ->
      func(element)
      childs = element.getChilds()
      if childs.length > 0
        for i in [0..childs.length-1]
          _map(childs[i])
    _map(@root)

class @RNAException extends Error
  constructor : (message) ->
    @message = message
    super message
  toString : () ->
    return "RNAException: " + @message