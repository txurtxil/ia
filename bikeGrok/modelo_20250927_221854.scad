// Parámetros Generales
wheel_diameter = 622; // Diámetro de la rueda en mm (ej. 700c)
tire_width = 25;
frame_size = 560; // Longitud del tubo del asiento en mm
seat_tube_angle = 73; // Ángulo del tubo del asiento (desde horizontal)
head_tube_angle = 73; // Ángulo del tubo de dirección (desde horizontal)
fork_length = 360;
rake = 45; // Offset de la horquilla en mm (rake típico para carretera)
chainstay_length = 410;
handlebar_width = 420;
crank_length = 172.5;
bb_height = 270; // Altura del eje de pedalier desde el suelo
frame_tube_diameter = 30; // Diámetro general para los tubos del cuadro (global para reutilización)
stem_length = 100; // Longitud de la potencia (stem) - Aumentado para mejor visibilidad

// Módulo principal que ensambla la bicicleta
bicycle();

module bicycle() {
    // Posición del eje de la rueda trasera
    rear_wheel_x = 0;
    rear_wheel_y = 0;
    rear_wheel_z = wheel_diameter / 2;

    // Posición del eje de pedalier
    bb_x = rear_wheel_x + chainstay_length;
    bb_y = 0;
    bb_z = bb_height;

    // Posición de la parte superior del tubo del asiento
    seat_tube_top_x = bb_x - frame_size * cos(seat_tube_angle);
    seat_tube_top_y = 0;
    seat_tube_top_z = bb_z + frame_size * sin(seat_tube_angle);

    // Posición aproximada del head tube (ajustada para tilt correcto)
    top_tube_length = 550; // Ajustable para wheelbase realista
    head_tube_length = 150; // Longitud típica del head tube
    head_tube_bottom_x = bb_x + top_tube_length * cos(head_tube_angle - 90);
    head_tube_bottom_z = bb_z - top_tube_length * sin(head_tube_angle - 90);
    head_tube_top_x = head_tube_bottom_x - head_tube_length * cos(head_tube_angle); // Signo - para tilt hacia atrás
    head_tube_top_y = 0;
    head_tube_top_z = head_tube_bottom_z + head_tube_length * sin(head_tube_angle);

    // Ruedas
    translate([rear_wheel_x, rear_wheel_y, rear_wheel_z]) wheel();
    front_wheel_x = head_tube_bottom_x + fork_length * cos(head_tube_angle) + rake * sin(head_tube_angle); // Ajustado con rake
    translate([front_wheel_x, rear_wheel_y, rear_wheel_z]) wheel();

    // Cuadro
    frame(bb_x, bb_y, bb_z, seat_tube_top_x, seat_tube_top_y, seat_tube_top_z, head_tube_top_x, head_tube_top_y, head_tube_top_z, head_tube_bottom_x, head_tube_bottom_z, head_tube_length);

    // Horquilla
    fork(head_tube_bottom_x, head_tube_bottom_z, front_wheel_x, rear_wheel_y, rear_wheel_z, bb_y);

    // Manillar
    translate([head_tube_top_x, head_tube_top_y, head_tube_top_z]) handlebars(head_tube_angle);

    // Asiento
    translate([seat_tube_top_x, seat_tube_top_y, seat_tube_top_z]) seat();

    // Transmisión
    translate([bb_x, bb_y, bb_z]) drivetrain(crank_length);
}

// Módulo para el cuadro de la bicicleta
module frame(bb_x, bb_y, bb_z, seat_tube_top_x, seat_tube_top_y, seat_tube_top_z, head_tube_top_x, head_tube_top_y, head_tube_top_z, head_tube_bottom_x, head_tube_bottom_z, head_tube_length) {
    // Definir posiciones que faltaban
    rear_wheel_x = bb_x - chainstay_length;
    rear_wheel_z = wheel_diameter / 2;

    // Tubo del asiento
    color("red")
    translate([bb_x, bb_y, bb_z])
    rotate([0, seat_tube_angle - 90, 0]) // Corregido para tilt correcto (negativo)
    cylinder(h = frame_size, d = frame_tube_diameter, center = false, $fn=50);

    // Tubo de dirección
    color("blue")
    translate([head_tube_bottom_x, bb_y, head_tube_bottom_z])
    rotate([0, head_tube_angle - 90, 0]) // Corregido para tilt correcto
    cylinder(h = head_tube_length, d = frame_tube_diameter + 10, center = false, $fn=50);

    // Tubo superior
    color("green")
    hull() {
        translate([seat_tube_top_x, bb_y, seat_tube_top_z]) sphere(d=frame_tube_diameter);
        translate([head_tube_top_x, bb_y, head_tube_top_z]) sphere(d=frame_tube_diameter);
    }

    // Tubo inferior
    color("orange")
    hull() {
        translate([bb_x, bb_y, bb_z]) sphere(d=frame_tube_diameter);
        translate([head_tube_bottom_x, bb_y, head_tube_bottom_z]) sphere(d=frame_tube_diameter);
    }

    // Vainas superiores (seat stays)
    color("purple") {
        hull() {
            translate([seat_tube_top_x, bb_y + frame_tube_diameter/2, seat_tube_top_z]) sphere(d=frame_tube_diameter);
            translate([rear_wheel_x, bb_y + frame_tube_diameter/2, rear_wheel_z]) sphere(d=frame_tube_diameter);
        }
        hull() {
            translate([seat_tube_top_x, bb_y - frame_tube_diameter/2, seat_tube_top_z]) sphere(d=frame_tube_diameter);
            translate([rear_wheel_x, bb_y - frame_tube_diameter/2, rear_wheel_z]) sphere(d=frame_tube_diameter);
        }
    }

    // Vainas inferiores (chain stays)
    color("brown") {
        hull() {
            translate([bb_x, bb_y + frame_tube_diameter/2, bb_z]) sphere(d=frame_tube_diameter);
            translate([rear_wheel_x, bb_y + frame_tube_diameter/2, rear_wheel_z]) sphere(d=frame_tube_diameter);
        }
        hull() {
            translate([bb_x, bb_y - frame_tube_diameter/2, bb_z]) sphere(d=frame_tube_diameter);
            translate([rear_wheel_x, bb_y - frame_tube_diameter/2, rear_wheel_z]) sphere(d=frame_tube_diameter);
        }
    }
}

// Módulo para la horquilla (nuevo)
module fork(head_tube_bottom_x, head_tube_bottom_z, front_wheel_x, rear_wheel_y, rear_wheel_z, bb_y) {
    color("blue") {
        hull() {
            translate([head_tube_bottom_x, bb_y + frame_tube_diameter/2, head_tube_bottom_z]) sphere(d=frame_tube_diameter);
            translate([front_wheel_x, rear_wheel_y + frame_tube_diameter/2, rear_wheel_z]) sphere(d=frame_tube_diameter);
        }
        hull() {
            translate([head_tube_bottom_x, bb_y - frame_tube_diameter/2, head_tube_bottom_z]) sphere(d=frame_tube_diameter);
            translate([front_wheel_x, rear_wheel_y - frame_tube_diameter/2, rear_wheel_z]) sphere(d=frame_tube_diameter);
        }
    }
}

// Módulo para las ruedas
module wheel() {
    rim_radius = wheel_diameter / 2 - tire_width / 2;
    hub_radius = 15; // Radio del buje para radios
    spoke_count = 12; // Número de radios (para simplicidad, radiales)

    rotate([90, 0, 0]) {
        // Neumático
        color("black")
        torus(r1 = wheel_diameter / 2, r2 = tire_width / 2);

        // Llanta
        color("silver")
        torus(r1 = rim_radius, r2 = 5);
    }

    // Radios mejorados (cilindros radiales)
    color("gray")
    for (i = [0 : 360 / spoke_count : 359]) {
        rotate([0, i, 0])
        translate([hub_radius, 0, 0])
        rotate([0, 90, 0])
        cylinder(h = rim_radius - hub_radius - 5, d = 2, $fn=20);
    }

    // Buje
    color("darkgray")
    rotate([0, 90, 0])
    cylinder(h = 50, d = 30, center = true, $fn=50);
}

// Módulo para el manillar - Ajustes para mejor visibilidad (aumentado stem_length, curvas más pronunciadas)
module handlebars(head_tube_angle) {
    stem_angle = 90 - head_tube_angle; // Ángulo positivo para stem forward (17° para 73°)

    // Potencia (stem) - Rotación corregida para pointing forward-up
    color("darkgray")
    rotate([0, stem_angle, 0]) // [0,17,0] para +x +z
    translate([0, 0, 0])
    cylinder(h = stem_length, d = 30, center = false, $fn=50);

    // Posición del manillar al final de la stem
    handlebar_attach_x = stem_length * cos(stem_angle); // Corregido: cos para x (horizontal), sin para z (vertical)
    handlebar_attach_z = stem_length * sin(stem_angle);

    // Manillar
    color("black")
    translate([handlebar_attach_x, 0, handlebar_attach_z])
    rotate([0, 90, 0])
    cylinder(h = handlebar_width, d = 25, center = true, $fn=50);

    // Curvas del manillar (mejoradas con hull, más pronunciadas)
    color("black") {
        hull() {
            translate([handlebar_attach_x, handlebar_width/2, handlebar_attach_z]) cylinder(h=1, d=25, $fn=50);
            translate([handlebar_attach_x - 50, handlebar_width/2, handlebar_attach_z - 80]) cylinder(h=1, d=25, $fn=50); // Curva más larga
        }
        hull() {
            translate([handlebar_attach_x, -handlebar_width/2, handlebar_attach_z]) cylinder(h=1, d=25, $fn=50);
            translate([handlebar_attach_x - 50, -handlebar_width/2, handlebar_attach_z - 80]) cylinder(h=1, d=25, $fn=50);
        }
    }
}

// Módulo para el asiento
module seat() {
    // Tija del sillín
    color("silver")
    translate([0, 0, -100])
    cylinder(h = 200, d = 27.2, center = false, $fn=50);

    // Sillín
    color("black")
    translate([0, 0, 100])
    rotate([0, -5, 0])
    cube([150, 70, 20], center = true);
}

// Módulo para la transmisión
module drivetrain(crank_length) {
    // Platos
    color("darkgray") {
        cylinder(d = 200, h = 5, center = true, $fn=50);
        cylinder(d = 160, h = 5, center = true, $fn=50);
    }

    // Bielas y pedales
    color("silver") {
        // Biela derecha
        rotate([90, 0, 0])
        cylinder(h = crank_length, d = 20, center = true, $fn=50);
        translate([0, crank_length / 2 + 20, 0]) pedal();

        // Biela izquierda
        rotate([90, 180, 0])
        cylinder(h = crank_length, d = 20, center = true, $fn=50);
        translate([0, -crank_length / 2 - 20, 0]) pedal();
    }

    // Cadena (mejorada: toroide elongado)
    color("gray")
    translate([-chainstay_length / 2, 0, -5])
    rotate([90, 0, 0])
    scale([2, 1, 1]) // Elongado en x para simular loop de cadena
    torus(r1 = chainstay_length / 3, r2 = 5);

    // Piñones
    translate([-chainstay_length, 0, 0])
    color("darkgray")
    rotate([0, 90, 0])
    cylinder(d1=120, d2=50, h=40, center=true, $fn=50);
}

// Módulo para un pedal
module pedal() {
    color("black")
    cube([80, 50, 15], center = true);
}

// Módulo para un toroide
module torus(r1, r2) {
    rotate_extrude(convexity = 10, $fn=50)
    translate([r1, 0, 0])
    circle(r = r2, $fn=50);
}
