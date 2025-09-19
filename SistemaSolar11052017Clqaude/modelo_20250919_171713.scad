// Sistema Solar en OpenSCAD - 11 de Mayo 2017, 20:00h
// Posiciones aproximadas basadas en cálculos orbitales

// Parámetros generales
base_radius = 200;
base_height = 5;
rod_radius = 1;

// Tamaños de planetas (escala relativa ajustada para visualización)
sun_radius = 15;
mercury_radius = 2;
venus_radius = 3;
earth_radius = 3.5;
mars_radius = 2.5;
jupiter_radius = 10;
saturn_radius = 8;
uranus_radius = 6;
neptune_radius = 5.5;

// Distancias orbitales (escala ajustada)
mercury_orbit = 25;
venus_orbit = 35;
earth_orbit = 45;
mars_orbit = 55;
jupiter_orbit = 75;
saturn_orbit = 95;
uranus_orbit = 115;
neptune_orbit = 135;

// Posiciones angulares aproximadas para el 11 de Mayo 2017 (en grados)
// Estas son estimaciones basadas en períodos orbitales
mercury_angle = 45;   // Mercurio se mueve rápido
venus_angle = 280;    // Venus en fase vespertina
earth_angle = 0;      // Referencia (posición base)
mars_angle = 195;     // Marte en oposición aproximada
jupiter_angle = 165;  // Júpiter visible en la noche
saturn_angle = 240;   // Saturno en buena posición
uranus_angle = 25;    // Movimiento lento
neptune_angle = 340;  // Movimiento muy lento

// Alturas de las varillas
mercury_height = 15;
venus_height = 18;
earth_height = 20;
mars_height = 17;
jupiter_height = 25;
saturn_height = 22;
uranus_height = 20;
neptune_height = 18;

// Colores
sun_color = [1, 1, 0];           // Amarillo
mercury_color = [0.7, 0.7, 0.7]; // Gris
venus_color = [1, 0.8, 0.4];     // Naranja claro
earth_color = [0.2, 0.6, 1];     // Azul
mars_color = [1, 0.4, 0.2];      // Rojo
jupiter_color = [0.8, 0.6, 0.4]; // Marrón claro
saturn_color = [1, 1, 0.8];      // Amarillo claro
uranus_color = [0.4, 0.8, 0.8];  // Cian
neptune_color = [0.2, 0.4, 1];   // Azul oscuro

module base() {
    color([0.3, 0.3, 0.3])
    cylinder(r=base_radius, h=base_height);
}

module rod(height) {
    color([0.5, 0.5, 0.5])
    cylinder(r=rod_radius, h=height);
}

module planet(radius, planet_color) {
    color(planet_color)
    sphere(r=radius);
}

module saturn_with_rings() {
    // Planeta Saturno
    color(saturn_color)
    sphere(r=saturn_radius);
    
    // Anillos
    color([0.8, 0.8, 0.6, 0.7])
    difference() {
        cylinder(r=saturn_radius*1.8, h=0.5, center=true);
        cylinder(r=saturn_radius*1.2, h=1, center=true);
    }
}

module place_planet(orbit_radius, angle, height, planet_radius, planet_color, has_rings=false) {
    // Calcular posición x,y basada en el ángulo
    x_pos = orbit_radius * cos(angle);
    y_pos = orbit_radius * sin(angle);
    
    translate([x_pos, y_pos, base_height]) {
        rod(height);
        translate([0, 0, height + planet_radius]) {
            if (has_rings) {
                saturn_with_rings();
            } else {
                planet(planet_radius, planet_color);
            }
        }
    }
}

module solar_system() {
    // Base
    base();
    
    // Sol en el centro
    translate([0, 0, base_height + sun_radius])
    planet(sun_radius, sun_color);
    
    // Planetas en sus posiciones del 11 de Mayo 2017
    place_planet(mercury_orbit, mercury_angle, mercury_height, mercury_radius, mercury_color);
    place_planet(venus_orbit, venus_angle, venus_height, venus_radius, venus_color);
    place_planet(earth_orbit, earth_angle, earth_height, earth_radius, earth_color);
    place_planet(mars_orbit, mars_angle, mars_height, mars_radius, mars_color);
    place_planet(jupiter_orbit, jupiter_angle, jupiter_height, jupiter_radius, jupiter_color);
    place_planet(saturn_orbit, saturn_angle, saturn_height, saturn_radius, saturn_color, has_rings=true);
    place_planet(uranus_orbit, uranus_angle, uranus_height, uranus_radius, uranus_color);
    place_planet(neptune_orbit, neptune_angle, neptune_height, neptune_radius, neptune_color);
}

// Módulo para mostrar las órbitas
module orbit_rings() {
    for(orbit = [mercury_orbit, venus_orbit, earth_orbit, mars_orbit, 
                 jupiter_orbit, saturn_orbit, uranus_orbit, neptune_orbit]) {
        color([0.3, 0.3, 0.3, 0.3])
        translate([0, 0, base_height + 0.1])
        difference() {
            cylinder(r=orbit + 0.5, h=0.2);
            cylinder(r=orbit - 0.5, h=0.3);
        }
    }
}

// Módulo para añadir etiquetas de fecha
module date_label() {
    color([1, 1, 1])
    translate([0, -base_radius + 20, base_height + 1])
    linear_extrude(height=1)
    text("11 Mayo 2017 - 20:00h", size=8, halign="center");
}

// Renderizar el sistema solar
solar_system();

// Añadir etiqueta de fecha
date_label();

// Descomentar para mostrar las órbitas
orbit_rings();

// Información adicional: líneas que conectan planetas próximos visualmente
module visual_connections() {
    // Conexión Venus-Júpiter (conjunción aproximada)
    color([1, 1, 1, 0.3])
    translate([0, 0, base_height + 25])
    rotate([0, 0, (venus_angle + jupiter_angle)/2])
    cube([jupiter_orbit - venus_orbit, 0.5, 0.5], center=true);
}
