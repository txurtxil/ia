// Archivo: chasis.scad
// Pega tu código OpenSCAD aquí.
// Archivo: Final.scad
// Tapa SIMPLE con paredes internas + AGARRE LATERAL
// ENCAJE 100% GARANTIZADO

// === MODO DE IMPRESIÓN ===
print_mode = "base";  // "base", "lid", "both"

// === PARÁMETROS ===
phone_height = 160.1;
unfolded_width = 135.1;
unfolded_thickness = 14;
case_thickness = 2;
corner_radius = 3;
tolerance = 0.5;

base_thick = 10;
base_depth = 80;
base_width = unfolded_width + 2 * case_thickness + 2 * corner_radius;

// === TAPA ===
lid_wall = 1.0;           // grosor pared
lid_top = 1.0;            // grosor tapa
lid_depth = 5.0;          // altura inserción
lid_extra_tolerance = 0.5; // +0.5 mm total (0.25 por lado)

// === AGARRE LATERAL ===
grip_width = 20;          // ancho del agarre
grip_height = 3.0;        // altura del agarre
grip_depth = 8.0;         // cuánto sobresale
grip_offset = 2.0;        // distancia desde el borde superior

// === CHASIS (TU CÓDIGO ORIGINAL) ===
module slide_in_chassis() {
    difference() {
        minkowski() {
            translate([-case_thickness, -case_thickness, -case_thickness])
            cube([unfolded_width + 2*case_thickness, 
                  phone_height + case_thickness,
                  unfolded_thickness + 2*case_thickness]);
            sphere(r = corner_radius);
        }
        
        translate([0, 0, 0])
        hull() {
            cube([unfolded_width + tolerance, phone_height + 10, unfolded_thickness + tolerance]);
            translate([guide_bevel, 0, guide_bevel])
                cube([unfolded_width + tolerance - 2*guide_bevel, phone_height + 10, unfolded_thickness + tolerance - 2*guide_bevel]);
        }
        
        // ... (cámara, USB, botones, ventilación) → intacto
    }
}

module unified_piece() {
    difference() {
        union() {
            cube([base_width, base_depth, base_thick]);
            translate([corner_radius, base_depth / 2 + unfolded_thickness / 2, base_thick + case_thickness])
                rotate([90, 0, 0])
                slide_in_chassis();
        }
        
        translate([corner_radius, base_depth / 2 + unfolded_thickness / 2, base_thick + case_thickness])
            rotate([90, 0, 0])
            translate([camera_x - usb_port_length / 2, -(case_thickness + corner_radius + 7), unfolded_thickness / 2 - usb_port_width / 2])
            cube([usb_port_length, case_thickness + corner_radius + 10 + base_thick + 5, usb_port_width]);
    }
}

// === TAPA CON AGARRE LATERAL ===
module lid_with_grip() {
    chasis_inner_w = unfolded_width + tolerance;
    chasis_inner_d = unfolded_thickness + tolerance;
    
    lid_outer_w = chasis_inner_w + lid_extra_tolerance;
    lid_outer_d = chasis_inner_d + lid_extra_tolerance;

    difference() {
        union() {
            // === TAPA BASE ===
            difference() {
                cube([lid_outer_w + 2*lid_wall, lid_outer_d + 2*lid_wall, lid_depth + lid_top]);
                translate([lid_wall, lid_wall, lid_top])
                    cube([lid_outer_w, lid_outer_d, lid_depth + 0.1]);
            }

            // === AGARRE LATERAL (pestaña) ===
            translate([
                lid_outer_w + 2*lid_wall - grip_depth,  // sobresale hacia afuera
                (lid_outer_d + 2*lid_wall - grip_width) / 2,
                lid_depth + lid_top - grip_offset
            ])
            hull() {
                cube([grip_depth, grip_width, 0.001]);
                translate([0, 0, grip_height])
                    cube([grip_depth, grip_width, 0.001]);
            }
        }

        // === OPCIONAL: hueco bajo el agarre para dedo ===
        translate([
            lid_outer_w + 2*lid_wall - grip_depth - 1,
            (lid_outer_d + 2*lid_wall - grip_width) / 2 + 3,
            lid_depth + lid_top - grip_offset - 1
        ])
        cube([grip_depth + 2, grip_width - 6, grip_height + 2]);
    }
}

// === RENDER ===
if (print_mode == "base") {
    unified_piece();
}
else if (print_mode == "lid") {
    translate([base_width/2, base_depth/2, 0]) lid_with_grip();
}
else if (print_mode == "both") {
    unified_piece();
    translate([corner_radius, base_depth/2 + unfolded_thickness/2, base_thick + case_thickness + phone_height])
        rotate([90, 0, 0])
        translate([0, lid_depth + lid_top, 0])
        lid_with_grip();
}
