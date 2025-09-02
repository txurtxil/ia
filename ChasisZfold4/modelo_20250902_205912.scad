// Improved Samsung Z Fold 4 DIY Chassis in OpenSCAD
// Corrections: Flex hole width increased to 140 (nearly full screen width for better central flex accommodation) and height to 50 (even taller for more clearance); label positions adjusted slightly; maintained other improvements

epsilon = 0.1;  // Slightly increased for better manifold resolution and cut overlaps

// Parameters (unchanged except where noted)
battery1_length = 67.4;  // EB-BF936ABY - rotated in slot for fit
battery1_width = 43.5;
battery1_thickness = 3.8 + 0.5;

battery2_length = 92.1;  // EB-BF937ABY - rotated in slot for fit
battery2_width = 42.0;
battery2_thickness = 3.2 + 0.5;

motherboard_length = 100;  // Rotated in slot for fit
motherboard_width = 50;
motherboard_thickness = 2 + 0.5;

usb_board_length = 40;
usb_board_width = 15;
usb_board_thickness = 1 + 0.5;

rear_camera_size = 30;  // Rear module
rear_camera_thickness = 5 + 0.5;

front_camera_length = 20;  // Front selfie module (approx)
front_camera_width = 10;
front_camera_thickness = 5 + 0.5;

speaker_size = 20;
speaker_width = 10;
speaker_thickness = 5;

screen_length = 147;
screen_width = 57;
screen_thickness = 2 + 1;

wall_thickness = 1.5;
base_thickness = 2;
overall_length = 160;
overall_width = 140;
overall_height = 22;

flex_clearance = 5;
screw_hole_dia = 2.5;
vent_hole_dia = 3;
vent_spacing = 3.5;  // Slightly denser for improved heat/lightness

// Modules
module component_slot(length, width, thickness) {
    cube([length + 1 + epsilon, width + 1 + epsilon, thickness + 1 + epsilon]);
}

module vent_grid(num_holes, direction) {
    for (i = [0:num_holes-1]) {
        if (direction == "horizontal") {
            translate([i * vent_spacing, 0, 0]) cylinder(h=wall_thickness + 2 + 2*epsilon, d=vent_hole_dia);
        } else {
            translate([0, i * vent_spacing, 0]) cylinder(h=wall_thickness + 2 + 2*epsilon, d=vent_hole_dia);
        }
    }
}

module label_text(text_str, pos_x, pos_y, pos_z, height=0.6) {
    translate([pos_x, pos_y, pos_z])  // Raised labels
        linear_extrude(height=height + epsilon)
            text(text_str, size=4, font="Liberation Sans", halign="left", valign="bottom");
}

// Main chassis base
union() {
    difference() {
        // Outer shell
        cube([overall_length, overall_width, overall_height]);
        
        // Hollow interior (with epsilon overlap)
        translate([wall_thickness, wall_thickness, base_thickness - epsilon])
            cube([overall_length - 2*wall_thickness + epsilon, overall_width - 2*wall_thickness + epsilon, overall_height + 2*epsilon]);
        
        // Component slots (with epsilon, rotations, and repositioning to eliminate overlaps)
        translate([10, 10, base_thickness - 0.5 - epsilon])
            component_slot(battery1_width, battery1_length, battery1_thickness);  // Rotated: x=43.5, y=67.4
        
        translate([108, 10, base_thickness - 0.5 - epsilon])
            component_slot(battery2_width, battery2_length, battery2_thickness);  // Rotated: x=42, y=92.1
        
        translate([55, 20, base_thickness - 0.5 - epsilon])
            component_slot(motherboard_width, motherboard_length, motherboard_thickness);  // Rotated: x=50, y=100
        
        translate([60, 125, base_thickness - 0.5 - epsilon])  // Slightly up to fit
            component_slot(usb_board_length, usb_board_width, usb_board_thickness);
        
        translate([120, 110, base_thickness - 0.5 - epsilon])  // Slightly up to avoid minor overlap
            component_slot(rear_camera_size, rear_camera_size, rear_camera_thickness);
        
        translate([10, 120, base_thickness - 0.5 - epsilon])
            component_slot(front_camera_length, front_camera_width, front_camera_thickness);
        
        translate([10, 100, base_thickness - 0.5 - epsilon])
            component_slot(speaker_size, speaker_width, speaker_thickness);
        
        translate([130, 95, base_thickness - 0.5 - epsilon])  // Slightly down to avoid overlap
            component_slot(speaker_size, speaker_width, speaker_thickness);
        
        // Screen mount (adjusted for smaller lip of 0.5mm)
        lip = 0.5;
        translate([(overall_length - (screen_length + 2*lip))/2, (overall_width - (screen_width + 2*lip))/2, overall_height - screen_thickness + 0.1 - epsilon])
            cube([screen_length + 2*lip + epsilon, screen_width + 2*lip + epsilon, screen_thickness + epsilon]);
        
        // Openings (USB port)
        translate([(overall_length - 20)/2, overall_width - wall_thickness - 1 - epsilon, base_thickness - epsilon])
            cube([20 + epsilon, wall_thickness + 2 + epsilon, 10 + epsilon]);
        
        // Rectangular camera holes
        translate([135 - 12.5, 115 - 10, -epsilon])  // Rear: centered, rectangular 25x20
            cube([25 + epsilon, 20 + epsilon, overall_height + 2*epsilon]);
        
        translate([20 - 10, 125 - 5, -epsilon])  // Front: centered, rectangular 20x10
            cube([20 + epsilon, 10 + epsilon, overall_height + 2*epsilon]);
        
        // Flex clearance (base, between batteries/motherboard)
        translate([53.5 + flex_clearance/2, 10 + 67.4/2, base_thickness - 1 - epsilon])
            cube([flex_clearance + epsilon, 10 + epsilon, 2 + epsilon]);
        
        // Screw holes
        translate([5, 5, -epsilon]) cylinder(h=overall_height + 2*epsilon, d=screw_hole_dia);
        translate([overall_length - 5, 5, -epsilon]) cylinder(h=overall_height + 2*epsilon, d=screw_hole_dia);
        translate([5, overall_width - 5, -epsilon]) cylinder(h=overall_height + 2*epsilon, d=screw_hole_dia);
        translate([overall_length - 5, overall_width - 5, -epsilon]) cylinder(h=overall_height + 2*epsilon, d=screw_hole_dia);
        
        // More/denser vents for heat/lightness (slightly offset to avoid edge issues)
        translate([wall_thickness + 10 + epsilon, wall_thickness + 10 + epsilon, -epsilon]) vent_grid(30, "horizontal");  // Bottom
        rotate([90, 0, 0]) translate([wall_thickness + 10 + epsilon, -overall_height + 1 + epsilon, -wall_thickness - 1 - epsilon]) vent_grid(30, "horizontal");  // Left side
        rotate([90, 0, 0]) translate([wall_thickness + 10 + epsilon, -overall_height + 1 + epsilon, -overall_width + wall_thickness + 1 + epsilon]) vent_grid(30, "horizontal");  // Right side
        translate([overall_length / 2 - 40 + epsilon, overall_width / 2 - 20 + epsilon, -epsilon]) vent_grid(25, "vertical");  // Back
        translate([20 + epsilon, 5 + epsilon, -epsilon]) vent_grid(20, "horizontal");  // Near batt1
        translate([overall_length - 50 + epsilon, 5 + epsilon, -epsilon]) vent_grid(20, "horizontal");  // Near batt2
        translate([(overall_length / 2) - 30 + epsilon, (overall_width / 2) + 10 + epsilon, -epsilon]) vent_grid(20, "horizontal");  // Near motherboard
        
        // Power button access (side hole)
        translate([overall_length - wall_thickness - epsilon, 80, 10])
            cube([wall_thickness + 2*epsilon, 5 + epsilon, 15 + epsilon]);
    }
    // Raised numbered labels on base floor
    label_text("1", 15, 15, base_thickness);  // Battery1
    label_text("2", 110, 15, base_thickness);  // Battery2
    label_text("3", 60, 25, base_thickness);  // Motherboard
    label_text("4", 65, 130, base_thickness);  // USB board
    label_text("5", 125, 115, base_thickness);  // Rear camera
    label_text("6", 15, 125, base_thickness);  // Front camera
    label_text("7", 15, 105, base_thickness);  // Speaker1
    label_text("8", 135, 100, base_thickness);  // Speaker2
    label_text("10", 58.5, 15, base_thickness);  // Flex (base)
    label_text("12", overall_length - 20, 85, base_thickness);  // Power button (near side)
    label_text("13", 70, overall_width - 15, base_thickness);  // USB opening
}

// Lid (separate, with engraving and vents, flex hole adjusted: wider (140, nearly full screen) and taller (50), centered for central flex)
module lid() {
    bezel_width = 4;  // Reduced for less gluing material (~2mm frame per side)
    flex_hole_width = 140;  // Nearly full screen width
    flex_hole_height = 50;  // Even taller for better fit
    translate([0, overall_width + 10, 0]) {
        union() {
            difference() {
                union() {
                    cube([overall_length, overall_width, wall_thickness]);
                    // Screen bezel
                    translate([(overall_length - screen_length - bezel_width)/2, (overall_width - screen_width - bezel_width)/2, wall_thickness - epsilon])
                        cube([screen_length + bezel_width, screen_width + bezel_width, 2 + epsilon]);
                }
                // Bezel cutout
                translate([(overall_length - screen_length - bezel_width)/2 + bezel_width/2, (overall_width - screen_width - bezel_width)/2 + bezel_width/2, wall_thickness - epsilon - 1])
                    cube([screen_length + epsilon, screen_width + epsilon, 4 + 2*epsilon]);
                // Flex hole in lid (adjusted dimensions, centered in x, positioned at bezel base)
                translate([(overall_length - flex_hole_width)/2, (overall_width - screen_width - bezel_width)/2, -epsilon])
                    cube([flex_hole_width + epsilon, flex_hole_height + epsilon, wall_thickness + 2*epsilon]);
                // Top vents
                translate([wall_thickness + 10 + epsilon, wall_thickness + 10 + epsilon, -epsilon]) vent_grid(30, "horizontal");
            }
            // Raised numbers on lid top
            label_text("9", (overall_length - screen_length)/2 + 5, (overall_width - screen_width)/2 - 10, wall_thickness);  // Screen
            label_text("11", (overall_length - flex_hole_width)/2 + 5, (overall_width - screen_width - bezel_width)/2 + bezel_width/2 - 20, wall_thickness);  // Flex (lid, adjusted further down for larger height)
        }
    }
}
lid();
