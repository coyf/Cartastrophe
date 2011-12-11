let f_i = float_of_int
let s_i = string_of_int
let s_f = string_of_float
let lastHeight = ref 0.
let lastColor = ref (0.,0.,0.)
let rec pgcd n m =
	
  if n > m then pgcd m n
  else if n = 0 then m
       else let r = m mod n in
            pgcd r n
let getHeight (x,y) interval =(* Printf.printf "%f,%f %u\n" x y interval; *)
try 
	lastHeight := Hashtbl.find ImageProcessing.heightHT 
	(int_of_float ((f_i interval) *.x),int_of_float ((f_i interval) *.y )); 
	!lastHeight
with Not_found -> !lastHeight

let getColor (x,y) interval =(* Printf.printf "%f,%f %u\n" x y interval; *)
try 
    let (r,g,b)= Hashtbl.find ImageProcessing.colorHT 
	(int_of_float ((f_i interval) *.x),int_of_float ((f_i interval) *.y )) in 
    lastColor := (((f_i r)/.255.),((f_i g)/.255.),((f_i b)/.255.));
	!lastColor
with Not_found -> !lastColor
let gH=getHeight
let gC=getColor
(* let getHeight (x,y) interval = (x-.y)*.(x+.y) *) 
let pp =function i->i:=!i+1 
module VertexMap =Map.Make (struct
       type t = int
          let compare = Pervasives.compare
end)

let calc_intersection (w,h) interval =
		
    
    let cx = w/interval 
	    and cy = h/interval 
        and vmap = ref VertexMap.empty
	    and vlist = ref [] 
	    and flist = ref []
			and ul = ref 0 
			and ur = ref 0 
			and mc = ref 0 
			and dl = ref 0
			and dr = ref 0
			and i= ref 2 (* iterator *)
		in 
    (* let count = (2*cx*cy -cy -cx +1)  
		in *)
		
		(* c=0 r=0 up left*)
(*		vlist := (0.,0.,(getHeight (0.,0.) interval))::!vlist; (*hackfix*) *)
        vmap:=VertexMap.add 1 ((gC (0.,0.) interval),(0.,0.,(getHeight (0.,0.)
        interval))) !vmap; (*1*)
		
		(* pp i : i initialis� � 2 *)
		for c = 0 to cy do
			(* c=c r=0 : up right*) 
			vmap:=VertexMap.add !i ((gC (f_i c+.1.,0.) interval),(f_i c +.1.,0.0,(getHeight (f_i c+.1.,0.)
            interval))) !vmap;
			pp i;
			for r = 0 to cx do
					ur := !i-1;
					if c = 1 then
						begin
							ul := !i-3*(cx)-1-4+r;
							dl := !i-3*(cx)-1-1+r;
						end
					else
						
						(* c=0 r=r *)
						if c = 0 then
							begin
								if r = 0 then
									ul := !i-2
								else
									ul := !i-3;
								(* down left *)
								vmap:=VertexMap.add !i ((gC (f_i c,f_i r+.1.)
                                interval),(f_i c,f_i r+.1.,
								(getHeight (f_i c,f_i r+.1.) interval))) !vmap;
								dl := !i;
								pp i;
							end
						else 
							begin
								ul := !i-2*(cx)-1-3;
								dl := !i-2*(cx)-1-1;
							end;
					
					(* middle center *)
					vmap:=VertexMap.add !i ((gC (f_i c+.0.5,f_i r+.0.5) interval),(f_i c+.0.5,f_i r+.0.5,
					(getHeight (f_i c+.0.5,f_i r+.0.5) interval))) !vmap;
					mc := !i;
					pp i;
					(* down right *)
					vmap:=VertexMap.add !i ((gC (f_i c+.1.,f_i r+.1.) interval),(f_i c+.1.,f_i r+.1.
					,(getHeight (f_i c+.1.,f_i r+.1.) interval))) !vmap;
					dr := !i;
					pp i;
					
					(* up *)
					flist := (!ul,!ur,!mc)::!flist;
					(* left *) 
					flist := (!ul,!mc,!dl)::!flist;
					(* right *)
					flist := (!ur,!mc,!dr)::!flist;
					(* down *)
					flist := (!dl,!mc,!dr)::!flist;
							
				done
			done;
    
    (!vmap,!flist)


let pixel2coord (x,y,z) =
	((float_of_int x)/.100.0,
	 (float_of_int y)/.100.0,
	 (float_of_int z)/.100.0) 
let rec createCoordList = function
	| [] -> []
	| c::l ->  (pixel2coord c)::(createCoordList l) 
let createObj filename (vList,fList)  =
		let file = 
			open_out_gen [Open_wronly; Open_creat; Open_trunc] 511 filename in
		let rec concatVertices = 
				function
				| [] -> "\n"
				| (x,y,z):: l -> concatVertices l ^
				"\nv "^(string_of_float x)^
				" "^(string_of_float z)^
				" "^(string_of_float y)
				
		in
		let rec concatFacets = 
				function
				| [] -> "\n"
				| (a,b,c):: l -> 
					concatFacets l ^
				"\nf "^(string_of_int a)^
				" "^(string_of_int b)^
				" "^(string_of_int c)
				
		in
		
		output_string file ("# Debut du fichier"^
												(concatVertices vList)^
												(concatFacets fList)^
												"\n# Fin du fichier "^filename);
		close_out file
