// Sistema Solar en OpenSCAD - 11 de Mayo 2017, 20:00h
// Con nombres y mayor realismo en planetas

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
moon_orbit = 52;  // Órbita para la Luna
mars_orbit = 60;
jupiter_orbit = 80;
saturn_orbit = 100;
uranus_orbit = 120;
neptune_orbit = 140;

// Posiciones angulares aproximadas para el 11 de Mayo 2017 (en grados)
mercury_angle = 45;   
venus_angle = 280;    
earth_angle = 0;
moon_angle = 30;      // Luna con ángulo diferente a la Tierra
mars_angle = 195;     
jupiter_angle = 165;  
saturn_angle = 240;   
uranus_angle = 25;    
neptune_angle = 340;  

// Alturas de las varillas
mercury_height = 15;
venus_height = 18;
earth_height = 20;
moon_height = 12;     // Luna más baja que la Tierra
mars_height = 17;
jupiter_height = 25;
saturn_height = 22;
uranus_height = 20;
neptune_height = 18;

// Colores base más realistas
sun_color = [1, 0.9, 0.3];           // Amarillo-naranja solar
mercury_color = [0.5, 0.5, 0.5];     // Gris oscuro
venus_color = [1, 0.8, 0.6];         // Crema-amarillo
earth_color = [0.2, 0.4, 0.8];       // Azul océano
earth_land_color = [0.3, 0.6, 0.2];  // Verde continentes
mars_color = [0.8, 0.3, 0.1];        // Rojo óxido
mars_polar_color = [0.9, 0.9, 0.9];  // Casquetes polares
jupiter_color = [0.8, 0.6, 0.4];     // Marrón claro
jupiter_band_color = [0.6, 0.4, 0.2]; // Bandas más oscuras
saturn_color = [0.9, 0.8, 0.6];      // Amarillo pálido
uranus_color = [0.4, 0.7, 0.9];      // Azul-verde
neptune_color = [0.2, 0.3, 0.9];     // Azul profundo

module base() {
    color([0.2, 0.2, 0.2])
    cylinder(r=base_radius, h=base_height);
}

module rod(height) {
    color([0.4, 0.4, 0.4])
    cylinder(r=rod_radius, h=height);
}

// Sol con corona
module realistic_sun() {
    // Núcleo brillante
    color(sun_color)
    sphere(r=sun_radius);
    
    // Corona solar (halo transparente)
    color([1, 1, 0.8, 0.3])
    sphere(r=sun_radius * 1.2);
}

// Mercurio con cráteres
module realistic_mercury() {
    color(mercury_color)
    sphere(r=mercury_radius);
    
    // Algunos cráteres simulados
    for(i = [0:5]) {
        rotate([i*60, i*45, 0])
        translate([mercury_radius*0.8, 0, 0])
        color([0.3, 0.3, 0.3])
        sphere(r=mercury_radius*0.15);
    }
}

// Venus con atmósfera densa
module realistic_venus() {
    // Superficie
    color(venus_color)
    sphere(r=venus_radius);
    
    // Atmósfera espesa
    color([1, 0.9, 0.7, 0.4])
    sphere(r=venus_radius * 1.1);
}

// Tierra con continentes y nubes
module realistic_earth() {
    // Océanos
    color(earth_color)
    sphere(r=earth_radius);
    
    // Continentes aproximados
    for(i = [0:8]) {
        rotate([i*40, i*80, i*120])
        translate([earth_radius*0.7, 0, 0])
        color(earth_land_color)
        sphere(r=earth_radius*0.3);
    }
    
    // Nubes
    color([1, 1, 1, 0.3])
    sphere(r=earth_radius * 1.05);
}

// Luna separada con su propio soporte
module realistic_moon() {
    color([0.7, 0.7, 0.7])
    sphere(r=2); // Luna más grande para que se sostenga bien
    
    // Cráteres lunares
    for(i = [0:4]) {
        rotate([i*72, i*45, 0])
        translate([1.5, 0, 0])
        color([0.5, 0.5, 0.5])
        sphere(r=0.3);
    }
}

// Marte con casquetes polares
module realistic_mars() {
    // Superficie rojiza
    color(mars_color)
    sphere(r=mars_radius);
    
    // Casquetes polares
    translate([0, 0, mars_radius*0.8])
    color(mars_polar_color)
    sphere(r=mars_radius*0.3);
    
    translate([0, 0, -mars_radius*0.8])
    color(mars_polar_color)
    sphere(r=mars_radius*0.25);
    
    // Algunas características oscuras
    for(i = [0:3]) {
        rotate([i*90, 0, 0])
        translate([mars_radius*0.6, 0, 0])
        color([0.5, 0.2, 0.1])
        sphere(r=mars_radius*0.2);
    }
}

// Júpiter con bandas y Gran Mancha Roja
module realistic_jupiter() {
    // Cuerpo principal
    color(jupiter_color)
    sphere(r=jupiter_radius);
    
    // Bandas atmosféricas
    for(z = [-0.6:0.3:0.6]) {
        translate([0, 0, jupiter_radius * z])
        color(jupiter_band_color)
        scale([1, 1, 0.1])
        sphere(r=jupiter_radius * 1.01);
    }
    
    // Gran Mancha Roja
    translate([jupiter_radius*0.8, 0, jupiter_radius*0.2])
    color([0.8, 0.2, 0.1])
    scale([1, 0.8, 0.6])
    sphere(r=jupiter_radius*0.15);
}

// Saturno con anillos detallados
module realistic_saturn() {
    // Planeta
    color(saturn_color)
    sphere(r=saturn_radius);
    
    // Sistema de anillos múltiples
    for(ring_size = [1.3:0.1:1.8]) {
        color([0.8, 0.7, 0.5, 0.6])
        difference() {
            cylinder(r=saturn_radius*ring_size, h=0.3, center=true);
            cylinder(r=saturn_radius*(ring_size-0.05), h=0.4, center=true);
        }
    }
    
    // División de Cassini (hueco en anillos)
    color([0.2, 0.2, 0.2, 0.8])
    difference() {
        cylinder(r=saturn_radius*1.55, h=0.4, center=true);
        cylinder(r=saturn_radius*1.5, h=0.5, center=true);
    }
}

// Urano inclinado con anillos tenues
module realistic_uranus() {
    rotate([98, 0, 0]) { // Inclinación característica de Urano
        color(uranus_color)
        sphere(r=uranus_radius);
        
        // Anillos verticales tenues
        for(ring = [1.8:0.2:2.2]) {
            color([0.4, 0.4, 0.4, 0.3])
            difference() {
                cylinder(r=uranus_radius*ring, h=0.2, center=true);
                cylinder(r=uranus_radius*(ring-0.05), h=0.3, center=true);
            }
        }
    }
}

// Neptuno con vientos
module realistic_neptune() {
    color(neptune_color)
    sphere(r=neptune_radius);
    
    // Manchas de tormenta
    translate([neptune_radius*0.7, 0, 0])
    color([0.1, 0.2, 0.8])
    sphere(r=neptune_radius*0.2);
}

// Módulo para crear etiquetas de nombres
module planet_label(text_content, orbit_radius, angle) {
    x_pos = orbit_radius * cos(angle);
    y_pos = orbit_radius * sin(angle);
    
    translate([x_pos, y_pos, base_height + 1])
    rotate([0, 0, angle])
    color([1, 1, 1])
    linear_extrude(height=0.5)
    text(text_content, size=3, halign="center", valign="center");
}

module place_planet(orbit_radius, angle, height, planet_type, planet_name) {
    // Calcular posición
    x_pos = orbit_radius * cos(angle);
    y_pos = orbit_radius * sin(angle);
    
    // Etiqueta en la base
    planet_label(planet_name, orbit_radius, angle);
    
    // Varilla y planeta
    translate([x_pos, y_pos, base_height]) {
        rod(height);
        translate([0, 0, height]) {
            if (planet_type == "mercury") realistic_mercury();
            else if (planet_type == "venus") realistic_venus();
            else if (planet_type == "earth") realistic_earth();
            else if (planet_type == "moon") realistic_moon();
            else if (planet_type == "mars") realistic_mars();
            else if (planet_type == "jupiter") realistic_jupiter();
            else if (planet_type == "saturn") realistic_saturn();
            else if (planet_type == "uranus") realistic_uranus();
            else if (planet_type == "neptune") realistic_neptune();
        }
    }
}

module solar_system() {
    // Base
    base();
    
    // Sol en el centro con etiqueta
    translate([0, 0, base_height + sun_radius])
    realistic_sun();
    
    // Etiqueta del Sol
    translate([0, 0, base_height + 1])
    color([1, 1, 1])
    linear_extrude(height=0.5)
    text("SOL", size=4, halign="center", valign="center");
    
    // Planetas con nombres
    place_planet(mercury_orbit, mercury_angle, mercury_height, "mercury", "MERCURIO");
    place_planet(venus_orbit, venus_angle, venus_height, "venus", "VENUS");
    place_planet(earth_orbit, earth_angle, earth_height, "earth", "TIERRA");
    place_planet(moon_orbit, moon_angle, moon_height, "moon", "LUNA");
    place_planet(mars_orbit, mars_angle, mars_height, "mars", "MARTE");
    place_planet(jupiter_orbit, jupiter_angle, jupiter_height, "jupiter", "JUPITER");
    place_planet(saturn_orbit, saturn_angle, saturn_height, "saturn", "SATURNO");
    place_planet(uranus_orbit, uranus_angle, uranus_height, "uranus", "URANO");
    place_planet(neptune_orbit, neptune_angle, neptune_height, "neptune", "NEPTUNO");
}

// Módulo para las órbitas
module orbit_rings() {
    for(orbit = [mercury_orbit, venus_orbit, earth_orbit, moon_orbit, mars_orbit, 
                 jupiter_orbit, saturn_orbit, uranus_orbit, neptune_orbit]) {
        color([0.5, 0.5, 0.5, 0.2])
        translate([0, 0, base_height + 0.1])
        difference() {
            cylinder(r=orbit + 0.3, h=0.1);
            cylinder(r=orbit - 0.3, h=0.2);
        }
    }
}

// Etiqueta de fecha
module date_label() {
    color([1, 1, 1])
    translate([0, base_radius - 15, base_height + 1])
    linear_extrude(height=0.5)
    text("11 Mayo 2017 - 20:00h", size=5, halign="center");
}

// Renderizar todo
solar_system();
orbit_rings();
date_label();
