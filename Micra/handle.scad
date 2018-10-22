insert_height=13.00;
insert_width=7.5;
insert_length=19.00;

insert_center_hole_length_offset=10.0;
insert_center_hole_width=5.5;

insert_middle_space_thickness = 1.5;

insert_wall_thickness=2.5;
insert_wall_height=16.0;

handle_depth=24;
handle_width=57;
handle_position_on_shorter_end=20;

handle_middle_cylinder_height=handle_width-handle_depth;

module draw_insert() {
    difference () {    
        difference() {
            cube([insert_height, insert_width, insert_length]);
            translate([insert_wall_thickness, insert_width/2-(insert_width-insert_wall_thickness*2)/2, insert_length-insert_wall_height]) {
               cube([insert_height-insert_wall_thickness*2, insert_width-insert_wall_thickness*2, insert_wall_height+.01]);
            }
        }
        translate([insert_height/2-insert_center_hole_width/2, -insert_center_hole_width*10, insert_length-insert_center_hole_length_offset-insert_center_hole_width/2]) {
               cube([insert_center_hole_width, insert_center_hole_width*20, insert_center_hole_width]);
        }
    }
}


module draw_handle() {
    //minkowski() {
        difference () {
    union() {
        translate([0, handle_middle_cylinder_height/2, 0]) {
                sphere(handle_depth/2);
        }
        translate([0, -handle_middle_cylinder_height/2, 0]) {
                sphere(handle_depth/2);
        }
         translate([0, handle_middle_cylinder_height/2, 0]) {
    rotate([90, 0, 0]) {
        cylinder(handle_middle_cylinder_height, handle_depth/2, handle_depth/2);
        }
    }
    }        translate([-handle_depth, -500, 10]) {

          cube([handle_depth*2, 1000, handle_depth]);
    }
}

}




module draw_assembly() {
    translate([-insert_height/2, handle_width/2-handle_position_on_shorter_end, 0]) {
        draw_insert();
    }        
    translate([0, 0, -handle_depth/2+insert_wall_thickness+1]) {
        draw_handle();
    }
}


draw_assembly();