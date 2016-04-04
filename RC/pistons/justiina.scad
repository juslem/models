shaft_diameter = 3.16; //schumi 3.16
cylinder_diameter = 12.1;  //12.1 xray
hole_edge_distance = 1.2;  //12mm borelle 1.2?
clip_inbetween_height = 2.8; //schumi 2.8

//TODO: opening gap as parameter

clip_diameter = 6.1; //schumi 6.1
clip_thickness = 0.3; //schumi 0.3
bottom_height = 0.6; //configurable as how strong the valve disc bottom floor is

num_piston_holes = 3;
num_valve_holes = 6;
piston_hole_diameter = 1.6;
valve_hole_diameter = 1.0;

disc_height = clip_inbetween_height /2;  //empirical: schumin clippiväliin 1.5
lock_inner_scaledown = 0.95;
lock_width = shaft_diameter + (cylinder_diameter/3 - hole_edge_distance);
lock_length = shaft_diameter + 1.2;
lock_height = disc_height;

top_clip_recess_radius = clip_diameter/2 + 0.1;

//mismatches all holes
//would require disc sides to pass some oil
//try $fn=8 -> 12
//hole_offset_degrees = 360/num_valve_holes/2;
hole_offset_degrees = 0;

render_disc_distance = 0;

$vpr = [70, 0, $t * 360];

$fn=20;

//male lock shape from adding lock (scaled down to fit the female shape)
module piston_disc() {
  translate ([0,0, - disc_height/2]) 
  scale([lock_inner_scaledown]) lock();
  base_disc(); 
}

//female lock shape from difference
module valve_disc() {
  difference() {
    base_disc();
    translate ([0,0, + lock_height/2 + bottom_height]) lock();
    translate ([0,0,0]) lock();
    translate ([0,0,-0.1]) cylinder(disc_height - bottom_height, top_clip_recess_radius, top_clip_recess_radius);
  } 
}

//shape used to lock the disc rotation
module lock() {
    //basic rectangular shape
    //cube([lock_length, lock_width, lock_height], true);
    
    //n-sided cylinder
    cylinder($fn=5, r1= lock_width/2, r2=lock_width/2, h=lock_height, center=true);
}

module holed_piston_disc() {
    difference() {
        piston_disc();
        piston_holes();
        shaft();
    }
}

module holed_valve_disc() {
    difference() {
        valve_disc();
        valve_holes();
    }
}

module piston_holes() {
    holes(hole_offset_degrees, num_piston_holes, piston_hole_diameter);
}

module valve_holes() {
    holes(0, num_valve_holes, valve_hole_diameter);
}


module base_disc() {
    color("DimGray", 0.8) cylinder(disc_height,cylinder_diameter/2,cylinder_diameter/2);
}

module holes(offset=0, num_of_holes=3, dia=1) {
    for ( i = [0:num_of_holes+1] ) {
		       	rotate( i*360/num_of_holes + offset, [0, 0, 1])		
				translate([cylinder_diameter/2 - dia/2 - hole_edge_distance, 0, 0]) cylinder(h=100, r=dia/2, center=true);}
}

//used primarily for shaft hole punching
module shaft() {
    translate ([0,0,-40 + disc_height + clip_thickness]) color("DarkGoldenrod", 1) cylinder(40, shaft_diameter/2, shaft_diameter/2);
}





//Actual drawing calls
module draw_demo() {
    rotate([180,0,0]) translate([0,0, - (disc_height - bottom_height)]) holed_valve_disc();


    translate([0,0, - clip_inbetween_height/2 + clip_thickness/2])
    rotate([180,0,0]) holed_piston_disc();     
    translate([0,0, -1]) shaft();
    //translate([0,0, - bottom_height + clip_thickness/2])

    translate([0,0, + clip_thickness/2])
    draw_clip(); //upper clip
    translate([0,0, - clip_inbetween_height - clip_thickness/2]) draw_clip(); //lower clip
}       

module draw_clip() {
    difference() {
       color("Black", 0.8) cylinder(clip_thickness, clip_diameter/2*0.9, clip_diameter/2*0.9);
    }
}

module draw_animation() {
        
    holed_piston_disc();
 
    translate([0,0, - 7 + $t]) 
        holed_valve_disc();
    }

module draw_print(num_of_pairs=1) {
//       for ( i = [0:num_of_pairs+1] ) {
           translate([cylinder_diameter + 2, 0,disc_height]) rotate([180,0,0]) holed_piston_disc();
           translate([0, 0,disc_height]) rotate([180,0,0]) holed_valve_disc();
  //     }
}

draw_print();  
//draw_demo();