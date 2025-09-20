// Funda para DJI Neo - Versión básica SIN BISAGRAS para eliminar warnings
// Dos piezas separadas: cuerpo y tapa independientes

$fn = 32;

// Parámetros principales
drone_width = 130;
drone_length = 157; 
drone_height = 25;
wall_thick = 3;
extra_space = 4;

// Dimensiones calculadas
inner_w = drone_width + extra_space;
inner_l = drone_length + extra_space;
inner_h = drone_height + extra_space;

outer_w = inner_w + 2 * wall_thick;
outer_l = inner_l + 2 * wall_thick;
outer_h = inner_h + wall_thick;

// Cubo redondeado básico
module round_box(w, l, h, r) {
    hull() {
        translate([r, r, 0]) cylinder(r=r, h=h);
        translate([w-r, r, 0]) cylinder(r=r, h=h);
        translate([r, l-r, 0]) cylinder(r=r, h=h);
        translate([w-r, l-r, 0]) cylinder(r=r, h=h);
    }
}

// Cuerpo de la funda - OBJETO ÚNICO SIMPLE
module case_body() {
    difference() {
        // Exterior
        round_box(outer_w, outer_l, outer_h, 6);
        
        // Cavidad interior principal
        translate([wall_thick, wall_thick, wall_thick]) {
            hull() {
                translate([6, 6, 0]) cylinder(r=4, h=inner_h+2);
                translate([inner_w-6, 6, 0]) cylinder(r=4, h=inner_h+2);
                translate([6, inner_l-6, 0]) cylinder(r=4, h=inner_h+2);
                translate([inner_w-6, inner_l-6, 0]) cylinder(r=4, h=inner_h+2);
            }
        }
        
        // Cuerpo central circular del drone
        translate([outer_w/2, outer_l/2, wall_thick-0.5])
            cylinder(d=100, h=inner_h+2);
        
        // Brazos del drone - 4 extensiones rectangulares
        arm_length = 35;
        arm_width = 12;
        
        // Frontal
        translate([outer_w/2 - arm_width/2, outer_l/2, wall_thick-0.5])
            cube([arm_width, arm_length, inner_h+2]);
        
        // Trasero  
        translate([outer_w/2 - arm_width/2, outer_l/2 - arm_length, wall_thick-0.5])
            cube([arm_width, arm_length, inner_h+2]);
        
        // Izquierdo
        translate([outer_w/2 - arm_length, outer_l/2 - arm_width/2, wall_thick-0.5])
            cube([arm_length, arm_width, inner_h+2]);
        
        // Derecho
        translate([outer_w/2, outer_l/2 - arm_width/2, wall_thick-0.5])
            cube([arm_length, arm_width, inner_h+2]);
        
        // Espacios para hélices en cada extremo
        translate([outer_w/2, outer_l/2 + 30, inner_h - 6])
            cylinder(d=80, h=10);
        translate([outer_w/2, outer_l/2 - 30, inner_h - 6])
            cylinder(d=80, h=10);
        translate([outer_w/2 - 30, outer_l/2, inner_h - 6])
            cylinder(d=80, h=10);
        translate([outer_w/2 + 30, outer_l/2, inner_h - 6])
            cylinder(d=80, h=10);
        
        // Puerto USB-C
        translate([outer_w/2-4, -1, wall_thick+12])
            cube([8, wall_thick+2, 6]);
        
        // LED indicador
        translate([outer_w/2+15, -1, wall_thick+8])
            cube([3, wall_thick+2, 3]);
        
        // Ventilación básica
        for(x=[15:12:outer_w-15]) {
            for(y=[15:12:outer_l-15]) {
                if(pow(x-outer_w/2,2) + pow(y-outer_l/2,2) > pow(55,2)) {
                    translate([x, y, -1])
                        cylinder(d=2.5, h=wall_thick+2);
                }
            }
        }
        
        // Hueco para imán
        translate([outer_w/2, outer_l-25, outer_h-2.5])
            cylinder(d=6.4, h=3);
    }
}

// Tapa independiente - OBJETO ÚNICO SIMPLE
module case_lid() {
    lid_thick = 2.5;
    lip_h = 4;
    fit_gap = 0.4;
    
    difference() {
        union() {
            // Base de la tapa
            round_box(outer_w, outer_l, lid_thick, 6);
            
            // Reborde de ajuste
            translate([wall_thick-fit_gap, wall_thick-fit_gap, lid_thick]) {
                linear_extrude(lip_h) {
                    difference() {
                        square([inner_w + 2*fit_gap, inner_l + 2*fit_gap]);
                        translate([1.5, 1.5])
                            square([inner_w + 2*fit_gap - 3, inner_l + 2*fit_gap - 3]);
                    }
                }
            }
        }
        
        // Agujero para abrir fácilmente
        translate([outer_w/2, outer_l-12, -1])
            cylinder(d=18, h=lid_thick + lip_h + 2);
        
        // Agujero pequeño para dedo
        translate([outer_w/2, outer_l-12, -1])
            cylinder(d=6, h=lid_thick + lip_h + 2);
        
        // Hueco para imán
        translate([outer_w/2, outer_l-25, -0.5])
            cylinder(d=6.4, h=2.5);
        
        // Texto opcional
        translate([outer_w/2, 15, lid_thick-0.5])
            linear_extrude(0.8)
                text("DJI NEO", size=8, halign="center", font="Arial:style=Bold");
    }
}

// Soportes internos opcionales
module internal_supports() {
    support_height = 4;
    positions = [
        [outer_w/2-25, outer_l/2-25],
        [outer_w/2+25, outer_l/2-25], 
        [outer_w/2-25, outer_l/2+25],
        [outer_w/2+25, outer_l/2+25]
    ];
    
    for(pos = positions) {
        translate([pos[0], pos[1], wall_thick])
            cylinder(d=6, h=support_height);
    }
}

// Cuerpo con soportes
module complete_body() {
    case_body();
    internal_supports();
}

// RENDERIZADO PRINCIPAL
echo("=== FUNDA DJI NEO - DOS PIEZAS SEPARADAS ===");
echo(str("Dimensiones: ", outer_w, "x", outer_l, "x", outer_h, "mm"));
echo("SIN BISAGRAS - Dos objetos independientes para eliminar warnings");

// Cuerpo de la funda
complete_body();

// Tapa separada
translate([outer_w + 10, 0, 0]) 
    case_lid();

/*
SOLUCIÓN DEFINITIVA A WARNINGS:
===============================
- SIN bisagras integradas (causaban problemas geométricos)
- DOS OBJETOS SEPARADOS completamente independientes
- Geometría ultra-simple sin intersecciones complejas
- Cada pieza es un manifold perfecto por separado

CARACTERÍSTICAS MANTENIDAS:
===========================
- Cavidad anatómica para DJI Neo (cuerpo + 4 brazos)
- Espacios para hélices plegadas
- Puerto USB-C y LED accesibles  
- Cierre magnético funcional
- Ventilación inteligente (evita zona del drone)
- Reborde de ajuste preciso
- Soportes internos de estabilización

OPCIONES DE BISAGRAS:
====================
Si quieres bisagras, puedes:
1. Usar esta versión (más confiable)
2. Añadir bisagras de piano externas
3. Usar velcro o cinta para unir las piezas
4. Imprimir por separado e instalar bisagras de plástico

IMPRESIÓN:
==========
- Material: PLA/PETG
- Altura: 0.2mm  
- Relleno: 15%
- Soportes: NO
- Dos piezas independientes = Sin problemas de manifold

Esta versión debe eliminar TODOS los warnings de manifold.
*/
