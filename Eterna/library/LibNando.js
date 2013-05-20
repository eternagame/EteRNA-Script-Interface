LibNando = {};

LibNando.RandomName = function() {
	// http://eterna.cmu.edu/web/script/2426641/
	function random_name()
	{
	    var syllabes = "..lexegezacebisousesarmaindirea.eratenberalavetiedorquanteisrion";
	    var seed = new Array();
	    seed[0] = Math.floor((Math.random()*0x10000));
	    seed[1] = Math.floor((Math.random()*0x10000));
	    seed[2] = Math.floor((Math.random()*0x10000));

	    var name = "";
	    var loops = seed[0] & 0x40 ? 4 : seed[1] & 0x40 ? 5 : 3;

	    while(loops) {
	        d = ((seed[2] >> 8) & 0x1F) << 1;
	        temp = (seed[0]+seed[1]+seed[2]) % 0x10000;
	        seed[0] = seed[1];
	        seed[1] = seed[2];
	        seed[2] = temp;

	        c = syllabes.charAt(d);
	        if( c != '.' ) name = name.concat(c);
	        c = syllabes.charAt(d+1);
	        if( c != '.' ) name = name.concat(c);

	        loops--;
	    }

	    return name.charAt(0).toUpperCase().concat(name.substr(1));
	}

	return random_name();
}

LibNando.BasePairDistance = function(structure1, structure2){
	// http://eterna.cmu.edu/web/script/2428623/
	
	function make_pair_table(structure)
	{
	    /* returns array representation of structure.
	       table[i] is 0 if unpaired or j if (i.j) pair.  */
	   var stack = new Array();
	   var table = new Array();

	   len = structure.length;
	   table[0] = len;

	   for (hx=0, i=1; i<=len; i++) {
	     switch (structure.charAt(i-1)) {
	       case '(':
	         stack[hx++]=i;
	         break;
	       case ')':
	         j = stack[--hx];
	         if (hx<0) {
	            outln("unbalanced brackets in make_pair_table");
	         }
	         table[i]=j;
	         table[j]=i;
	         break;
	       default:   /* unpaired base, usually '.' */
	         table[i]= 0;
	         break;
	      }
	   }
	   if (hx!=0) {
	      outln("unbalanced brackets in make_pair_table");
	   }
	   return(table);
	}

	function bp_distance(str1, str2)
	{
	  /* dist = {number of base pairs in one structure but not in the other} */

	  dist = 0;
	  t1 = make_pair_table(str1);
	  t2 = make_pair_table(str2);

	  l = (t1[0]<t2[0])?t1[0]:t2[0];    /* minimum of the two lengths */

	  for (i=1; i<=l; i++) {
	     if (t1[i]!=t2[i]) {
	       if (t1[i]>i) dist++;
	       if (t2[i]>i) dist++;
	     }
	  }
	  return dist;
	}


	d = bp_distance(structure1, structure2);

	return d;
}