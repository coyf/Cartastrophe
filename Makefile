FILES=imageProcessing.ml objMaker.ml fridi.ml interface.ml main.ml
INTERFACES=${FILES:.ml=.mli}
all:
	ocamlopt -I +sdl -I +lablgtk2 -I +lablGL bigarray.cmxa sdl.cmxa sdlloader.cmxa lablgtk.cmxa lablgl.cmxa lablglut.cmxa lablgtkgl.cmxa gtkInit.cmx -o cartastrophe ${INTERFACES} ${FILES} 
clean:
	rm -f *.cm? *.o ~* 
