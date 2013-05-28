LibJnicol = {};

LibJnicol.GetPuzzleDetail = function(puzzleid, value){
	// http://eterna.cmu.edu/web/script/2501835/
	
	// puzzle_details is intended to be a library call where the user only needs to make 1 call:
	// var puz = new puzzle_details( puzzleid ); to retrieve all information about a puzzle necessary to solve it.

	// This section of the script is meant to be a library call to
	// retrieve all information about a puzzle necessary to solve it.
	// The user only needs to call puz = new puzzle_details( puzzleid );
	// to obtain the puzzle details. The start of main script code section
	// is where the user code should begin.
	function constraint_details()
	{
	  this.max_gc = -1;
	  this.min_au = -1;
	  this.min_gu = -1;
	  this.max_consecutive_g = -1;
	  this.max_consecutive_c = -1;
	  this.max_consecutive_a = -1;
	}
	function shape_details()
	{
	  this.structure = '';
	  this.aptamer = null;
	  this.bonus = 0;
	}
	function puzzle_details( id )
	{
	  this.id = -1;
	  this.title = '';
	  this.locks = '';
	  this.begin_sequence = '';
	  this.use_tails = 0;
	  this.shape = new Array();
	  this.constraint = null;

	  var i, j, st, st2, res, obj;
	  var params = { type: "puzzle", nid: id };
	  res = AjaxManager.querySync("GET", Application.GET_URI, params);

	  if( res == undefined || res.data == undefined || res.data.puzzle == undefined ) return;
	  if( res.data.puzzle.id != undefined ) {
	    this.id = res.data.puzzle.id;
	  }
	  if( res.data.puzzle.title != undefined ) {
	    this.title = res.data.puzzle.title;
	  }
	  if( res.data.puzzle.usetails != undefined ) {
	    this.use_tails = res.data.puzzle.usetails;
	  }
	  if( res.data.puzzle.constraints != undefined ) {
	    st = res.data.puzzle.constraints;
	    if( (i = st.indexOf('GC')) > -1 ) {
	      i = st.indexOf(',',i); if( (j = st.indexOf(',',i+1)) < 0 ) { j = st.length; }
	      if( this.constraint == null ) { this.constraint = new constraint_details(); }
	      this.constraint.max_gc = st.substring(i+1, j);
	    }
	    if( (i = st.indexOf('AU')) > -1 ) {
	      i = st.indexOf(',',i); if( (j = st.indexOf(',',i+1)) < 0 ) { j = st.length; }
	      if( this.constraint == null ) { this.constraint = new constraint_details(); }
	      this.constraint.min_au = st.substring(i+1, j);
	    }
	    if( (i = st.indexOf('GU')) > -1 ) {
	      i = st.indexOf(',',i); if( (j = st.indexOf(',',i+1)) < 0 ) { j = st.length; }
	      if( this.constraint == null ) { this.constraint = new constraint_details(); }
	      this.constraint.min_gu = st.substring(i+1, j);
	    }
	    if( (i = st.indexOf('CONSECUTIVE_G')) > -1 ) {
	      i = st.indexOf(',',i); if( (j = st.indexOf(',',i+1)) < 0 ) { j = st.length; }
	      if( this.constraint == null ) { this.constraint = new constraint_details(); }
	      this.constraint.max_consecutive_g = st.substring(i+1, j);
	    }
	    if( (i = st.indexOf('CONSECUTIVE_C')) > -1 ) {
	      i = st.indexOf(',',i); if( (j = st.indexOf(',',i+1)) < 0 ) { j = st.length; }
	      if( this.constraint == null ) { this.constraint = new constraint_details(); }
	      this.constraint.max_consecutive_c = st.substring(i+1, j);
	    }
	    if( (i = st.indexOf('CONSECUTIVE_A')) > -1 ) {
	      i = st.indexOf(',',i); if( (j = st.indexOf(',',i+1)) < 0 ) { j = st.length; }
	      if( this.constraint == null ) { this.constraint = new constraint_details(); }
	      this.constraint.max_consecutive_a = st.substring(i+1, j);
	    }
	  }
	  if( res.data.puzzle.objective != undefined ) {
	    obj = eval( res.data.puzzle.objective );
	    for( i = 0; i < obj.length; i++ ) {
	      this.shape[i] = new shape_details();
	      this.shape[i].structure = obj[i].secstruct;
	      if( obj[i].site != undefined ) {
	        this.shape[i].aptamer = obj[i].site.toString().split(',');
	      }
	      if( obj[i].concentration != undefined ) {
	        this.shape[i].bonus =  Math.round(-63.47 * Math.log((obj[i].concentration+2700)/6))/100;
	      }
	    }
	  } else if( res.data.puzzle.secstruct != undefined ) {
	    this.shape[0] = new shape_details();
	    this.shape[0].structure = res.data.puzzle.secstruct;
	  }
	  if( res.data.puzzle.locks != undefined ) {
	    this.locks = res.data.puzzle.locks;
	  }
	  if( res.data.puzzle.beginseq != undefined ) {
	    this.begin_sequence = res.data.puzzle.beginseq.toUpperCase();
	  } else {
	    i = this.shape[0].structure.length;
	    st = 'A'; st2 = 'o';
	    while( i > 0 ) {
	      if( i & 1 ) {
	        this.begin_sequence += st;
	        this.locks += st2;
	      }
	      i >>= 1;
	      st += st; st2 += st2;
	    }
	  }
	}

	// Start of main script code. Only need to call the following to retrieve
	// the structure, constraints, locks and begin sequence details of a puzzle.
	// Also, retrieves all switch structures and bonus energy.
	puz = new puzzle_details( puzzleid );

	// display the puzzle details
	out('id = '+puz.id+', title = '+puz.title);
	outln('');
	if( puz.constraint != null || puz.uses_tails == 1 ) {
	  if( puz.uses_tails == 1 ) { out('add tails; '); }
	  if( puz.constraint.max_gc > -1 ) { out('max GC = '+puz.constraint.max_gc+'; '); }
	  if( puz.constraint.min_au > -1 ) { out('min AU = '+puz.constraint.min_au+'; '); }
	  if( puz.constraint.min_gu > -1 ) { out('min GU = '+puz.constraint.min_gu+'; '); }
	  if( puz.constraint.max_consecutive_g > -1 ) { out('max consecutive G = '+puz.constraint.max_consecutive_g+'; '); }
	  if( puz.constraint.max_consecutive_c > -1 ) { out('max consecutive C = '+puz.constraint.max_consecutive_c+'; '); }
	  if( puz.constraint.max_consecutive_a > -1 ) { out('max consecutive A = '+puz.constraint.max_consecutive_a+'; '); }
	  outln('');
	}
	if( puz.constraint != null ) {}
	outln(puz.locks);
	outln(puz.begin_sequence);
	if( puz.shape.length > 0 ) { outln(puz.shape[0].structure); }
	if( puz.shape.length > 0 && puz.shape[0].bonus != 0 ) { outln('bonus = '+puz.shape[0].bonus); }
	if( puz.shape.length > 1 ) { outln(puz.shape[1].structure); }
	if( puz.shape.length > 1 && puz.shape[1].bonus != 0 ) { outln('bonus = '+puz.shape[1].bonus); }
	if( puz.shape.length > 2 ) { outln(puz.shape[2].structure); }
	if( puz.shape.length > 2 && puz.shape[2].bonus != 0 ) { outln('bonus = '+puz.shape[2].bonus); }

	return 0;
}