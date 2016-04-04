shaft_diameter = 3.0;
cylinder_diameter = 12.1;  //12.1 xray
hole_edge_distance = 1.2;  //12mm borelle 1.2?
clip_inbetween_height = 2.8; //schumi

//TODO: opening gap as parameter

clip_diameter = 6.1; //schumi 6.1
clip_thickness = 0.3; //schumi 0.3
bottom_height = 0.6;
num_upper_holes = 3;
num_lower_holes = 6;
upper_hole_diameter = 1.6;
lower_hole_diameter = 1.0;

disc_height = clip_inbetween_height /2;  //empirical: schumin clippiväliin 1.5
lock_inner_scaledown = 0.95;
lock_width = shaft_diameter + (cylinder_diameter/3 - hole_edge_distance);
lock_length = shaft_diameter + 1.2;
lock_height = disc_height;


top_clip_recess_radius = clip_diameter/2 + 0.1;

//mismatches all holes
//would require disc sides to pass some oil
//try $fn=8 -> 12
//hole_offset_degrees = 360/num_upper_holes/2;
hole_offset_degrees = 0;

render_disc_distance = 0;

$vpr = [70, 0, $t * 360];

$fn=20;

//male lock shape from adding lock (scaled down to fit the female shape)
module upper_disc() {
  translate ([0,0, - disc_height/2]) 
  scale([lock_inner_scaledown]) lock();
  base_disc(); 
}

//female lock shape from difference
module lower_disc() {
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

module holed_upper_disc() {
    difference() {
        upper_disc();
        upper_holes();
        //lower_holes();
        shaft();
    }
}

module holed_lower_disc() {
    difference() {
        lower_disc();
        lower_holes();
        //shaft();;
    }
}

module upper_holes() {
    holes(hole_offset_degrees, num_upper_holes, upper_hole_diameter);
}

module lower_holes() {
    holes(0, num_lower_holes, lower_hole_diameter);
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
    rotate([180,0,0]) translate([0,0, - (disc_height - bottom_height)]) holed_lower_disc();


    translate([0,0, - clip_inbetween_height/2 + clip_thickness/2])
    rotate([180,0,0]) holed_upper_disc();     
    translate([0,0, -1]) shaft();
    //translate([0,0, - bottom_height + clip_thickness/2])

    translate([0,0, + clip_thickness/2])
    draw_clip(); //upper
    translate([0,0, - clip_inbetween_height - clip_thickness/2]) draw_clip(); //lower
}       

module draw_clip() {
    difference() {
       color("Black", 0.8) cylinder(clip_thickness, clip_diameter/2*0.9, clip_diameter/2*0.9);
    }
}

module draw_animation() {
        
    holed_upper_disc();
 
    translate([0,0, - 7 + $t]) 
        holed_lower_disc();
    }

module draw_print(num_of_pairs=1) {
//       for ( i = [0:num_of_pairs+1] ) {
           translate([cylinder_diameter + 2, 0,disc_height]) rotate([180,0,0]) holed_upper_disc();
           translate([0, 0,disc_height]) rotate([180,0,0]) holed_lower_disc();
  //     }
}

draw_print();  
//draw_demo();