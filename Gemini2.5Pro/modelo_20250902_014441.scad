// Torre Eiffel Detallada en OpenSCAD

// Calidad del renderizado
$fn = 50;

// Dimensiones generales
base_width = 125;
primera_plataforma_y = 57;
segunda_plataforma_y = 115;
tercera_plataforma_y = 276;
altura_total = 324;

// Módulo para un solo pilar
module pilar(altura, base, tope) {
    linear_extrude(height = altura, convexity = 10, twist = 0, scale = [tope/base, tope/base]) {
        square(base, center = true);
    }
}

// Módulo para la celosía (simplificada)
module celosia(largo, ancho, grosor) {
    for (i = [0 : 10 : largo]) {
        translate([0, 0, i]) cube([ancho, grosor, 1], center = true);
        translate([0, 0, i]) cube([grosor, ancho, 1], center = true);
    }
}

// Base de la Torre
module base() {
    for (x = [-1, 1]) {
        for (y = [-1, 1]) {
            translate([x * base_width / 2, y * base_width / 2, 0]) {
                pilar(10, 20, 15);
            }
        }
    }
    // Arcos de la base
    difference() {
        translate([0, 0, 30]) cube([base_width, base_width, 10], center = true);
        translate([0, 0, 30]) cylinder(h = 12, r = base_width / 2.5, center = true);
    }
}

// Cuerpo inferior
module cuerpo_inferior() {
    for (x = [-1, 1]) {
        for (y = [-1, 1]) {
            // Pilares principales
            hull() {
                translate([x * base_width / 2.2, y * base_width / 2.2, 10]) pilar(primera_plataforma_y - 10, 15, 8);
                translate([x * base_width / 4, y * base_width / 4, primera_plataforma_y]) cube([1,1,1]);
            }
            // Celosía interna (simplificada)
            translate([x*base_width/3, y*base_width/3, primera_plataforma_y/2]) rotate([90,0,0]) celosia(primera_plataforma_y, 10, 1);
        }
    }
}

// Primera plataforma
module primera_plataforma() {
    translate([0, 0, primera_plataforma_y]) {
        difference() {
            cube([70, 70, 5], center = true);
            translate([0,0,-2]) cube([40,40,10], center=true);
        }
        // Barandillas
        translate([0, 0, 5]) difference() {
            cube([72, 72, 2], center = true);
            cube([70, 70, 2], center = true);
        }
    }
}

// Cuerpo medio
module cuerpo_medio() {
    for (x = [-1, 1]) {
        for (y = [-1, 1]) {
            hull() {
                translate([x * 30, y * 30, primera_plataforma_y + 5]) pilar(segunda_plataforma_y - primera_plataforma_y - 5, 8, 4);
                translate([x * 15, y * 15, segunda_plataforma_y]) cube(1);
            }
        }
    }
}

// Segunda plataforma
module segunda_plataforma() {
    translate([0, 0, segunda_plataforma_y]) {
        difference() {
            cube([35, 35, 4], center = true);
            translate([0,0,-2]) cube([20,20,8], center=true);
        }
        // Barandillas
        translate([0, 0, 4]) difference() {
            cube([37, 37, 2], center = true);
            cube([35, 35, 2], center = true);
        }
    }
}

// Cuerpo superior
module cuerpo_superior() {
    hull() {
        translate([0, 0, segunda_plataforma_y + 4]) {
            for (x = [-1, 1]) {
                for (y = [-1, 1]) {
                    translate([x * 12, y * 12, 0]) pilar(tercera_plataforma_y - segunda_plataforma_y - 4, 4, 1.5);
                }
            }
        }
        translate([0, 0, tercera_plataforma_y]) cube([5,5,1], center=true);
    }
}

// Plataforma superior y antena
module cima() {
    translate([0, 0, tercera_plataforma_y]) {
        // Plataforma
        cube([10, 10, 3], center = true);
        // Antena
        translate([0, 0, 1.5]) cylinder(h = altura_total - tercera_plataforma_y, r1 = 1, r2 = 0.5, center = false);
    }
}

// Ensamblaje de la Torre Eiffel
base();
cuerpo_inferior();
primera_plataforma();
cuerpo_medio();
segunda_plataforma();
cuerpo_superior();
cima();

