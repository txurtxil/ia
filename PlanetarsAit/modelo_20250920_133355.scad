// Sistema Solar en OpenSCAD - 11 de Mayo 2017, 20:00h
// Con nombres y mayor realismo en planetas

// Parámetros generales - Base ultra compacta + Sistema modular
base_radius = 80;   // Base muy pequeña (16cm diámetro total)
base_height = 3;    
rod_radius = 0.6;   // Palillos muy finos

// PLANETAS EN MÚLTIPLES NIVELES VERTICALES para ahorrar espacio horizontal
// Tamaños optimizados para impresión detallada
sun_radius = 8;     
mercury_radius = 2.5; 
venus_radius = 3.5; 
earth_radius = 4;   
mars_radius = 3;    
jupiter_radius = 10; 
saturn_radius = 8;  
uranus_radius = 6;   
neptune_radius = 5.5; 

// SISTEMA DE 3 ANILLOS CONCÉNTRICOS en lugar de una sola órbita grande
// Anillo interior - planetas rocosos
mercury_orbit = 18;
venus_orbit = 24;
earth_orbit = 30;
moon_orbit = 35;    

// Anillo medio - Marte solo
mars_orbit = 45;

// Anillo exterior - gigantes gaseosos (más compactos)
jupiter_orbit = 55;
saturn_orbit = 62;
uranus_orbit = 69;
neptune_orbit = 75;

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

// ALTURAS ESCALONADAS - Planetas en diferentes niveles para crear efecto 3D dinámico
sun_height = 8;       // Sol en el centro, altura media
mercury_height = 12;  // Planetas interiores más altos
venus_height = 15;    
earth_height = 18;    
moon_height = 8;      // Luna más baja
mars_height = 22;     // Marte alto para destacar
jupiter_height = 25;  // Júpiter el más alto (es el más grande)
saturn_height = 20;   // Saturno medio-alto  
uranus_height = 14;   // Planetas exteriores en descenso
neptune_height = 10;  // Neptuno más bajo

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

// Mercurio con cráteres más detallados
module realistic_mercury() {
    color(mercury_color)
    sphere(r=mercury_radius);
    
    // Cráteres más grandes y detallados
    for(i = [0:8]) {
        rotate([i*40, i*60, 0])
        translate([mercury_radius*0.7, 0, 0])
        color([0.3, 0.3, 0.3])
        sphere(r=mercury_radius*0.2);
    }
    
    // Cráter grande tipo Caloris
    rotate([45, 0, 0])
    translate([mercury_radius*0.6, 0, 0])
    color([0.2, 0.2, 0.2])
    sphere(r=mercury_radius*0.3);
}

// Venus con atmósfera densa y características superficiales
module realistic_venus() {
    // Superficie con variaciones
    color(venus_color)
    sphere(r=venus_radius);
    
    // Características volcánicas simuladas
    for(i = [0:6]) {
        rotate([i*50, i*70, 0])
        translate([venus_radius*0.6, 0, 0])
        color([0.9, 0.6, 0.4])
        sphere(r=venus_radius*0.15);
    }
    
    // Atmósfera espesa con bandas
    color([1, 0.9, 0.7, 0.3])
    sphere(r=venus_radius * 1.15);
    
    // Bandas atmosféricas
    for(z = [-0.8:0.4:0.8]) {
        translate([0, 0, venus_radius * z])
        color([1, 0.8, 0.6, 0.2])
        scale([1, 1, 0.1])
        sphere(r=venus_radius * 1.1);
    }
}

// Tierra con continentes más detallados y nubes
module realistic_earth() {
    // Océanos base
    color(earth_color)
    sphere(r=earth_radius);
    
    // Continentes más realistas y grandes
    // América
    rotate([0, 0, 0])
    translate([earth_radius*0.6, 0, 0])
    color(earth_land_color)
    scale([1, 2, 1.5])
    sphere(r=earth_radius*0.25);
    
    // Europa/África
    rotate([0, 0, 60])
    translate([earth_radius*0.7, 0, 0])
    color(earth_land_color)
    scale([0.8, 1, 1.2])
    sphere(r=earth_radius*0.2);
    
    // Asia
    rotate([0, 0, 120])
    translate([earth_radius*0.65, 0, 0])
    color(earth_land_color)
    scale([1.2, 1.5, 1])
    sphere(r=earth_radius*0.22);
    
    // Australia
    rotate([0, 0, -60])
    translate([earth_radius*0.8, 0, -earth_radius*0.3])
    color(earth_land_color)
    sphere(r=earth_radius*0.12);
    
    // Casquetes polares
    translate([0, 0, earth_radius*0.85])
    color([1, 1, 1])
    sphere(r=earth_radius*0.25);
    
    translate([0, 0, -earth_radius*0.85])
    color([1, 1, 1])
    sphere(r=earth_radius*0.3);
    
    // Sistema de nubes más realista
    color([1, 1, 1, 0.25])
    sphere(r=earth_radius * 1.08);
    
    // Formaciones nubosas
    for(i = [0:5]) {
        rotate([i*30, i*60, 0])
        translate([earth_radius*1.05, 0, 0])
        color([1, 1, 1, 0.4])
        scale([2, 1, 0.5])
        sphere(r=earth_radius*0.15);
    }
}

// Luna con detalles de cráteres y mares
module realistic_moon() {
    color([0.7, 0.7, 0.7])
    sphere(r=2.5); // Un poco más grande
    
    // Cráteres principales más grandes
    // Cráter Tycho
    rotate([30, 0, 0])
    translate([2, 0, 0])
    color([0.5, 0.5, 0.5])
    sphere(r=0.4);
    
    // Cráter Copérnico
    rotate([60, 45, 0])
    translate([2.2, 0, 0])
    color([0.4, 0.4, 0.4])
    sphere(r=0.3);
    
    // Múltiples cráteres pequeños
    for(i = [0:12]) {
        rotate([i*30, i*45, i*60])
        translate([1.8, 0, 0])
        color([0.5, 0.5, 0.5])
        sphere(r=0.15);
    }
    
    // Mares lunares (zonas más oscuras)
    for(i = [0:4]) {
        rotate([i*72, i*30, 0])
        translate([1.5, 0, 0])
        color([0.4, 0.4, 0.4])
        scale([1.5, 1, 1])
        sphere(r=0.5);
    }
}

// Marte con detalles geológicos mejorados
module realistic_mars() {
    // Superficie rojiza base
    color(mars_color)
    sphere(r=mars_radius);
    
    // Valles Mariner (gran cañón)
    rotate([10, 0, 0])
    translate([mars_radius*0.5, 0, 0])
    color([0.6, 0.2, 0.1])
    scale([2, 0.3, 0.2])
    sphere(r=mars_radius*0.3);
    
    // Monte Olimpo (volcán gigante)
    rotate([45, 0, 0])
    translate([mars_radius*0.7, 0, 0])
    color([0.9, 0.4, 0.2])
    scale([0.8, 0.8, 1.5])
    sphere(r=mars_radius*0.2);
    
    // Casquetes polares más detallados
    translate([0, 0, mars_radius*0.8])
    color([0.95, 0.95, 0.95])
    sphere(r=mars_radius*0.35);
    
    translate([0, 0, -mars_radius*0.8])
    color([0.9, 0.9, 0.95])
    sphere(r=mars_radius*0.25);
    
    // Características oscuras (antiguos océanos)
    for(i = [0:4]) {
        rotate([i*60, i*40, 0])
        translate([mars_radius*0.6, 0, 0])
        color([0.5, 0.2, 0.1])
        scale([1.2, 1, 0.8])
        sphere(r=mars_radius*0.2);
    }
    
    // Tormentas de polvo
    color([0.8, 0.6, 0.4, 0.2])
    sphere(r=mars_radius * 1.05);
}

// Júpiter con más detalles atmosféricos
module realistic_jupiter() {
    // Cuerpo principal
    color(jupiter_color)
    sphere(r=jupiter_radius);
    
    // Bandas atmosféricas más detalladas
    for(z = [-0.8:0.15:0.8]) {
        translate([0, 0, jupiter_radius * z])
        color([0.6, 0.4, 0.2])
        scale([1, 1, 0.08])
        sphere(r=jupiter_radius * 1.02);
    }
    
    // Bandas más claras intercaladas
    for(z = [-0.7:0.3:0.7]) {
        translate([0, 0, jupiter_radius * z])
        color([0.9, 0.7, 0.5])
        scale([1, 1, 0.05])
        sphere(r=jupiter_radius * 1.01);
    }
    
    // Gran Mancha Roja más detallada
    translate([jupiter_radius*0.8, 0, jupiter_radius*0.2])
    color([0.8, 0.2, 0.1])
    scale([1.5, 1, 0.8])
    sphere(r=jupiter_radius*0.18);
    
    // Tormenta más pequeña
    translate([jupiter_radius*0.7, 0, -jupiter_radius*0.4])
    color([0.7, 0.3, 0.2])
    scale([1, 0.8, 0.6])
    sphere(r=jupiter_radius*0.1);
    
    // Remolinos atmosféricos
    for(i = [0:3]) {
        rotate([0, 0, i*90])
        translate([jupiter_radius*0.6, 0, jupiter_radius*0.1])
        color([0.8, 0.5, 0.3])
        scale([0.8, 0.8, 0.4])
        sphere(r=jupiter_radius*0.08);
    }
}

// Saturno con sistema de anillos más complejo
module realistic_saturn() {
    // Planeta con bandas sutiles
    color(saturn_color)
    sphere(r=saturn_radius);
    
    // Bandas atmosféricas de Saturno
    for(z = [-0.6:0.3:0.6]) {
        translate([0, 0, saturn_radius * z])
        color([0.8, 0.7, 0.5])
        scale([1, 1, 0.06])
        sphere(r=saturn_radius * 1.01);
    }
    
    // Sistema de anillos múltiples más detallado
    // Anillo C (interior, tenue)
    color([0.7, 0.6, 0.4, 0.4])
    difference() {
        cylinder(r=saturn_radius*1.3, h=0.2, center=true);
        cylinder(r=saturn_radius*1.1, h=0.3, center=true);
    }
    
    // Anillo B (principal, más brillante)
    color([0.85, 0.75, 0.6, 0.8])
    difference() {
        cylinder(r=saturn_radius*1.6, h=0.3, center=true);
        cylinder(r=saturn_radius*1.35, h=0.4, center=true);
    }
    
    // División de Cassini (hueco)
    color([0.1, 0.1, 0.1, 0.9])
    difference() {
        cylinder(r=saturn_radius*1.7, h=0.4, center=true);
        cylinder(r=saturn_radius*1.65, h=0.5, center=true);
    }
    
    // Anillo A (exterior)
    color([0.8, 0.7, 0.5, 0.7])
    difference() {
        cylinder(r=saturn_radius*2.0, h=0.25, center=true);
        cylinder(r=saturn_radius*1.75, h=0.35, center=true);
    }
    
    // Anillo F (muy exterior y fino)
    color([0.9, 0.8, 0.6, 0.5])
    difference() {
        cylinder(r=saturn_radius*2.1, h=0.1, center=true);
        cylinder(r=saturn_radius*2.05, h=0.2, center=true);
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

// Módulo para crear etiquetas de nombres más pequeñas
module planet_label(text_content, orbit_radius, angle) {
    x_pos = orbit_radius * cos(angle);
    y_pos = orbit_radius * sin(angle);
    
    translate([x_pos, y_pos, base_height + 0.5])
    rotate([0, 0, angle])
    color([1, 1, 1])
    linear_extrude(height=0.3)
    text(text_content, size=2, halign="center", valign="center");
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
    // Base compacta
    base();
    
    // Sol en el centro con altura propia
    translate([0, 0, base_height])
    rod(sun_height);
    translate([0, 0, base_height + sun_height + sun_radius])
    realistic_sun();
    
    // Etiqueta del Sol
    translate([0, 0, base_height + 0.5])
    color([1, 1, 1])
    linear_extrude(height=0.3)
    text("SOL", size=2.5, halign="center", valign="center");
    
    // SISTEMA COMPACTO: Planetas en anillos concéntricos con alturas variadas
    place_planet(mercury_orbit, mercury_angle, mercury_height, "mercury", "MERCURIO");
    place_planet(venus_orbit, venus_angle, venus_height, "venus", "VENUS");
    place_planet(earth_orbit, earth_angle, earth_height, "earth", "TIERRA");
    place_planet(moon_orbit, moon_angle, moon_height, "moon", "LUNA");
    place_planet(mars_orbit, mars_angle, mars_height, "mars", "MARTE");
    place_planet(jupiter_orbit, jupiter_angle, jupiter_height, "jupiter", "JUPITER");
    place_planet(saturn_orbit, saturn_angle, saturn_height, "saturn", "SATURNO");
    place_planet(uranus_orbit, uranus_angle, uranus_height, "uranus", "URANO");
    place_planet(neptune_orbit, neptune_angle, neptune_height, "neptuno", "NEPTUNO");
}

// Módulo alternativo: SISTEMA MODULAR DESMONTABLE
// Opción para imprimir en piezas separadas si la base sigue siendo grande
module modular_section(section_name, planets_list) {
    color([0.3, 0.3, 0.3])
    translate([0, 0, -1])
    linear_extrude(height=1)
    text(section_name, size=3, halign="center");
    
    // Conectores para ensamblar secciones
    color([0.4, 0.4, 0.4])
    for(angle = [0:90:270]) {
        rotate([0, 0, angle])
        translate([base_radius-5, 0, 0])
        cylinder(r=2, h=base_height+2);
    }
}

// Versión modular dividida en 4 sectores (imprimir por separado si necesario)
module sector_1() { // Planetas rocosos internos
    intersection() {
        solar_system();
        translate([0, 0, -10])
        linear_extrude(height=100)
        polygon([[0,0], [100,0], [100,100], [0,100]]);
    }
}

module sector_2() { // Marte y asteroides
    intersection() {
        solar_system();
        translate([0, 0, -10])
        linear_extrude(height=100)
        polygon([[0,0], [0,100], [-100,100], [-100,0]]);
    }
}

module sector_3() { // Gigantes gaseosos 1
    intersection() {
        solar_system();
        translate([0, 0, -10])
        linear_extrude(height=100)
        polygon([[0,0], [-100,0], [-100,-100], [0,-100]]);
    }
}

module sector_4() { // Gigantes gaseosos 2
    intersection() {
        solar_system();
        translate([0, 0, -10])
        linear_extrude(height=100)
        polygon([[0,0], [0,-100], [100,-100], [100,0]]);
    }
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

// Etiqueta de fecha más pequeña
module date_label() {
    color([1, 1, 1])
    translate([0, base_radius - 8, base_height + 0.5])
    linear_extrude(height=0.3)
    text("11 Mayo 2017", size=2.5, halign="center");
}

// RENDERIZADO PRINCIPAL - Versión compacta completa
solar_system();
orbit_rings();
date_label();

// DESCOMENTA UNA DE ESTAS OPCIONES SI LA BASE SIGUE SIENDO MUY GRANDE:

// Opción A: Imprimir por sectores (descomenta solo uno a la vez)
// sector_1(); // Solo planetas rocosos internos
// sector_2(); // Solo Marte 
// sector_3(); // Solo Júpiter y Saturno
// sector_4(); // Solo Urano y Neptuno

// Opción B: Solo planetas principales (sin Luna)
/*
module compact_version() {
    base();
    translate([0, 0, base_height + sun_height + sun_radius])
    realistic_sun();
    
    place_planet(15, 0, 12, "mercury", "MERCURIO");
    place_planet(20, 90, 15, "venus", "VENUS"); 
    place_planet(25, 180, 18, "earth", "TIERRA");
    place_planet(30, 270, 22, "mars", "MARTE");
    place_planet(40, 45, 25, "jupiter", "JUPITER");
    place_planet(50, 135, 20, "saturn", "SATURNO");
    place_planet(60, 225, 14, "uranus", "URANO");
    place_planet(70, 315, 10, "neptune", "NEPTUNO");
}
*/

// INFORMACIÓN DE IMPRESIÓN:
// Base actual: 16cm diámetro × ~3cm alto
// Si aún es grande, usar los sectores o la versión compacta comentada arriba
