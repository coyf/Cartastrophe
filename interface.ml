let width = ref 800
let height= ref 600
let backgroundimage= ref "madamecatastrophe.jpeg"
let interval = ref 10
let filenameimage = ref ""
(*Ouverture de la fenetre*)
(* On crée la surface d'affichage en doublebuffering *)
(* let newDisplay () =(Sdlvideo.set_video_mode (!width) (!height) [`DOUBLEBUF]
let display = ref (newDisplay ())
let setSize w h = width:=w;height:=h;display :=newDisplay () *)
(*let setSize w h = ()*)
(* Affiche une image à l'écran *)
(* let showSurface img = 
	let d = Sdlvideo.display_format img in
		Sdlvideo.blit_surface d !display ();
		Sdlvideo.flip !display
		 *)
(*Chargement d'une image *)
let load_picture = Sdlloader.load_image

let setCaption = Sdlwm.set_caption
(*string of stringoption*)
(*Ouverture de la fenetre*)
let window = GWindow.window
    ~title:"Cartastrophe"
    ~resizable:true
    ~height:!height
    ~width:!width ()
(*Permettre l'ajout de widgets dans window*)
let vbox = GPack.vbox
    ~border_width:1
    ~height:((!height)/3)	
    ~width:((!width)/3)
    ~packing:window#add ()
(*emplacement boutons*)
let hbox = GPack.hbox 
    ~border_width:2
    ~height:(2*(!height)/3) (* Les enfants sont espacés de 5 pixels. *)
    ~width:(2*(!width)/3)
    ~packing:vbox#add ()
let bbox = GPack.button_box `VERTICAL
    ~layout:`SPREAD
    ~packing:(hbox#pack ~expand:false) ()
(*Création des différents cadres*)
(*let frame_image_origin = GBin.frame 
    ~label:"Original Image"
    ~packing:vbox#add ()*)
let frame_image_treated = GBin.frame
    ~label: "Image traitée"
    ~width:((!width)/10)
    ~packing:vbox#add ()
let frame_visualisation = GBin.frame
    ~label:"Visualisation"
    ~packing:hbox#add ()
(*Bouton d'aide*)
exception IsNone
let s_of_s_o = function
    | Some x -> x
    | _ -> raise IsNone
let image_filter =GFile.filter
    ~name:"Fichier image"
    ~patterns:["*.bmp";"*.png";"*.jpg";"*.jpeg"] ()
(*let help_message _=
  let dlg _= GWindow.message_dialog
    ~message:"1. Cliquez sur le premier bouton, celui permettant de selection 
    votre image /n 2. Votre image est prétraité et afficher dans le cadre du bas
    de l'interface /n 3. Vous pouvez nagiver dans la modélisation 3D de votre 
    image en deux dimensions"
    ~parent:window
    ~destroy_with_parent:false
    ~use_markup:true
    ~message_type:`QUESTION
    ~position:`CENTER_ON_PARENT
    ~buttons:GWindow.Buttons.yes_no () in
  let res = dlg#run () = `NO in
  dlg#destroy ();
  res
let help =
    let button= GButton.button
	~stock:`HELP
	~packing:bbox#add () in
	GMisc.image ~stock:`HELP ~packing: button#set_image ();
    (*sw*) (button#connect#clicked ~callback:help_message);
    button*)
let about_button =
  let dlg = GWindow.about_dialog
    ~authors:["Quatrographes (<quatrographes@gmail.com>)"]
    ~copyright:"Copyright © 2011-2012 Cartastrophe Project"
    ~license:"EPITA 2015 "
    ~version:"42.42"
    ~website:"http://cartastro0.wordpress.com/"
    ~website_label:"Le site Cartastrophe"
    ~position:`CENTER_ON_PARENT
    ~parent:window
    ~destroy_with_parent:true () in
  let btn = GButton.button 
    ~stock:`ABOUT 
    ~packing:bbox#add () in
  GMisc.image ~stock:`ABOUT ~packing:btn#set_image ();
  btn#connect#clicked (fun () -> ignore (dlg#run ()); dlg#misc#hide ());
  btn
(*Bouton quitter*)
let quit =
    let button = GButton.button
	~stock:`QUIT
	~packing:bbox#add () in
    GMisc.image ~stock:`QUIT ~packing:button#set_image ();
    (button#connect#clicked ~callback:GMain.quit);
    button
(*Creation d'une box pour l'image*)
(*let imgbox = GPack.box `VERTICAL
    ~spacing: 5
    ~border_width: 5
    ~packing: window#add () *)
    
(*affichage de l'image d'un GMisc.image*)
(*let imageview = GMisc.image
    ~file:!filenameimage
    ~packing:frame_image_treated#add ()*)
let area = GlGtk.area [`DOUBLEBUFFER;`RGBA;`DEPTH_SIZE 16;`BUFFER_SIZE 16]
    ~height:(2*(!height)/3) 
    ~width:(2*(!width)/3)
    ~packing:frame_visualisation#add ()

let image_processing filename = 
    let img = load_picture filename in
(* On récupère les dimensions *)
    let (w, h) = ImageProcessing.get_dims img in
(* Traite l'image *)
    let breaks = (ImageProcessing.detect_areas img) in
    begin
    (* ObjMaker.createObj (filename^".obj") (ObjMaker.calc_intersection (w,h)
    !interval); *)
    let (vmap,flist) = ObjMaker.calc_intersection (w,h) !interval
    in
    Fridi.display area (2*(!height)/3) (2*(!width)/3) vmap flist;
    	(* Imprime les bordures sur l'image *)
    ImageProcessing.print_borders img breaks;
    	(* Affiche l'image modifiée *)
    Sdlvideo.save_BMP img (filename^"-traite.bmp");
    Sdlvideo.save_BMP (ImageProcessing.crisscross img (w,h) (!interval))
    (filename^"-crisscross.bmp");
    filenameimage := filename;

    end		

let may_print btn () = Gaux.may image_processing btn#filename

let map_button = 
let button = GFile.chooser_button
    ~title:"Choix de la carte"
    ~action:`OPEN
    (*~set_filter:image_filter*)
    ~packing:bbox#add () in
    (button#connect#selection_changed (may_print button));
GMisc.image ~file:!filenameimage ~packing:frame_image_treated#add();
    button
(* Suppress warnings *)
let sw foo = ()
(*(*image de fond*)
let background_image = GMisc.image
    ~file:!backgroundimage
    ~packing:window#add ()*)
(* Initialisation SDL,GTK2 et ouverture de la fenetre *)
let init () = 
	begin
		Sdl.init [`EVERYTHING];
		(*Sdlevent.enable_events Sdlevent.all_events_mask;*)
		(*GMain.init ();*)
		(*sw*) (window#connect#destroy ~callback:GMain.quit);
		window#show ();
		GMain.Main.main ()
	end
