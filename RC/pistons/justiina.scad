//Author: Jussi Lemmetty
//This work is licensed under a
//Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License
//http://creativecommons.org/licenses/by-nc-nd/4.0/

/*
data_vector = [cylinder_diameter,
                shaft_diameter,  
                bottom_height,
                [ clip_inbetween_height,
                 clip_diameter,
                 clip_thickness],
                [ num_piston_holes
                  piston_hole_diameter
                  num_valve_holes
                  valve_hole_diameter]                
               ]
*/

//////////////////////////////////////////////
// Basher Sabertooth shock configuration
///////////////////////////////////////////////
sabertooth_clips = [3.5, 7, 0.5];  //let's leave a shim-space with 0.5mm)
sabertooth_holes1 = [3, 2.0, 6, 1.5];
configuration_sabertooth1 = [16, 2.4, 0.7, sabertooth_clips, sabertooth_holes1];
///////////////////////////////////////////////

///////////////////////////////////////////////
// XRay shock configuration
///////////////////////////////////////////////
xray_clips = [2, 6, 0.3];
xray_holes1 = [3, 1.4, 6, 1.2];
xray_holes2 = [2, 1.6, 4, 1.4];
xray_holes3 = [2, 1.7, 4, 1.4];
configuration_xray1 = [12.1, 3.0, 0.4, xray_clips, xray_holes1];
///////////////////////////////////////////////

///////////////////////////////////////////////
// Schumacher Big Bore shock configuration
///////////////////////////////////////////////
schumi_clips = [2.8, 6.1, 0.3];
schumi_holes1 = [3, 1.4, 6, 1.2];
configuration_schumi1 = [13, 3.25, 0.4, schumi_clips, schumi_holes1];
///////////////////////////////////////////////

//Select the used configuration here:
configuration = configuration_sabertooth1;

//Shock cylinder inner diameter
cylinder_diameter = configuration[0];

//Shock shaft diameter
shaft_diameter = configuration[1];

//Distance of holes from disc rim
hole_edge_distance = cylinder_diameter/12;

//TODO: opening gap as parameter

//configure how strong the valve disc bottom floor is
bottom_height = configuration[2];

//e-clip configuration
//Distance between e-clips
clip_inbetween_height = configuration[3][0];
clip_diameter = configuration[3][1];
clip_thickness = configuration[3][2];

//Hole configuration
num_piston_holes = configuration[4][0];
piston_hole_diameter = configuration[4][1];
num_valve_holes = configuration[4][2];
valve_hole_diameter = configuration[4][3];

//TODO: allow to parameterize differing disc sizes
disc_height = clip_inbetween_height /2;

//Lock parameters
lock_inner_scaledown = 0.92;
lock_width = shaft_diameter + (cylinder_diameter/4 - hole_edge_distance);
lock_height = disc_height;
lock_length = cylinder_diameter/2; //not used in cylindrical lock shape

top_clip_recess_radius = clip_diameter/2 + 0.6;

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
    cube([lock_length, lock_width, lock_height], true);
    
    //n-sided cylinder
    //cylinder($fn=5, r1= lock_width/2, r2=lock_width/2, h=lock_height, center=true);

    //TODO: cross-shaped lock?
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

//Use this to make a mock assembly
module draw_demo() {
    rotate([180,0,0]) translate([0,0, - (disc_height - bottom_height)]) holed_valve_disc();

    translate([0,0, - clip_inbetween_height/2 + clip_thickness/2])
    rotate([180,0,0]) holed_piston_disc();     
    translate([0,0, -1]) shaft();
    
    translate([0,0, + clip_thickness/2])
    draw_clip(); //upper clip
    translate([0,0, - clip_inbetween_height - clip_thickness/2]) draw_clip(); //lower clip
}       

module draw_clip() {
    difference() {
       color("Black", 0.8) cylinder(clip_thickness, clip_diameter/2*0.9, clip_diameter/2*0.9);
    }
}

//TODO
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