// Archivo: Chasis.scad
// Pega tu código OpenSCAD aquí.
// Archivo: Final.scad
// Chasis + Base + Tapa para Samsung Galaxy Z Fold 4
// USB-C: ACCESO TOTAL (tu corte original se mantiene intacto)

// === MODO DE IMPRESIÓN (PARA STL) ===
print_mode = "base";  // "base" → base+chasis | "lid" → tapa | "both" → vista previa

// === PARÁMETROS ORIGINALES (NO TOCAR) ===
phone_height = 160.1;
unfolded_width = 135.1;
unfolded_thickness = 14;
case_thickness = 2;
corner_radius = 3;
tolerance = 0.5;

camera_cutout_width = 45;
camera_cutout_height = 70;
camera_x = 20;
camera_y_from_top = 40;

usb_port_length = 80;
usb_port_width = 10;

button_length_vol = 25;
button_length_power = 15;
guide_bevel = 1;

// === BASE ===
base_thick = 10;
base_depth = 80;
base_width = unfolded_width + 2 * case_thickness + 2 * corner_radius;

// === TAPA (NUEVA) ===
lid_thickness = case_thickness + 1.5;  // Más gruesa para agarre
lid_clearance = 0.15;
lid_bevel = 0.8;

// === CHASIS (100% TU CÓDIGO ORIGINAL) ===
module slide_in_chassis() {
    difference() {
        minkowski() {
            translate([-case_thickness, -case_thickness, -case_thickness])
            cube([unfolded_width + (2*case_thickness), 
                  phone_height + case_thickness,
                  unfolded_thickness + (2*case_thickness)]);
            sphere(r = corner_radius);
        }
        
        translate([0, 0, 0]) {
            hull() {
                cube([unfolded_width + tolerance, phone_height + 10, unfolded_thickness + tolerance]);
                translate([guide_bevel, 0, guide_bevel])
                  cube([unfolded_width + tolerance - (2*guide_bevel), phone_height + 10, unfolded_thickness + tolerance - (2*guide_bevel)]);
            }
        }
        
        cam_x_center = camera_x;
        cam_y_center = phone_height - camera_y_from_top;
        translate([
            cam_x_center - camera_cutout_width/2, 
            cam_y_center - camera_cutout_height/2, 
            unfolded_thickness - (corner_radius + 5)
        ]) { 
            cube([camera_cutout_width, camera_cutout_height, case_thickness + corner_radius + 10]);
        }
        
        usb_x_center = camera_x; 
        usb_z_center = unfolded_thickness / 2;
        translate([
            usb_x_center - usb_port_length/2,
            -(case_thickness + corner_radius + 5),
            usb_z_center - usb_port_width/2
        ]) {
            cube([usb_port_length, case_thickness + corner_radius + 10, usb_port_width]);
        }
        
        btn_y_vol = phone_height / 2 + 15;
        btn_y_pow = phone_height / 2 - 25;
        translate([-(case_thickness + corner_radius + 5), btn_y_vol, 0])
            cube([case_thickness + corner_radius + 10, button_length_vol, unfolded_thickness]);
        translate([-(case_thickness + corner_radius + 5), btn_y_pow, 0])
            cube([case_thickness + corner_radius + 10, button_length_power, unfolded_thickness]);
        
        for (i = [20:20:phone_height-20]) {
            translate([-(case_thickness + corner_radius + 5), i, 0])
                cube([case_thickness + corner_radius + 10, 15, unfolded_thickness]);
            translate([unfolded_width, i, 0])
                cube([case_thickness + corner_radius + 10, 15, unfolded_thickness]);
        }
    }
}

// === TU unified_piece() – 100% SIN MODIFICAR ===
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
            translate([
                camera_x - usb_port_length / 2,
                -(case_thickness + corner_radius + 7),
                unfolded_thickness / 2 - usb_port_width / 2
            ])
            cube([
                usb_port_length,
                case_thickness + corner_radius + 10 + base_thick + 5,
                usb_port_width
            ]);
    }
}

// === TAPA REMOVIBLE (NUEVA) ===
module lid() {
    inner_w = unfolded_width + tolerance;
    inner_d = unfolded_thickness + tolerance;
    w_large = inner_w - 2 * lid_clearance;
    d_large = inner_d - 2 * lid_clearance;
    w_small = w_large - 2 * lid_bevel;
    d_small = d_large - 2 * lid_bevel;

    difference() {
        hull() {
            translate([0, 0, lid_thickness])
                minkowski() {
                    cube([w_large - 2*corner_radius, d_large - 2*corner_radius, 0.001]);
                    cylinder(r = corner_radius, h = 0.001);
                }
            translate([lid_bevel, lid_bevel, 0])
                cube([w_small, d_small, lid_thickness - lid_bevel]);
        }
        // Agarre
        translate([w_large/2, d_large/2, lid_thickness - 0.8])
            cylinder(r = 7, h = 2, center = true);
    }
}

// === EXPORTAR STL SEGÚN MODO ===
if (print_mode == "base") {
    // Solo base + chasis → STL
    unified_piece();
}
else if (print_mode == "lid") {
    // Solo tapa → STL
    translate([base_width/2, base_depth/2, 0])
        lid();
}
else if (print_mode == "both") {
    // Vista previa
    unified_piece();
    translate([corner_radius, base_depth/2 + unfolded_thickness/2, base_thick + case_thickness + phone_height])
        rotate([90, 0, 0])
        translate([0, lid_thickness, 0])
        lid();
}
