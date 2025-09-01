// Medidas de la botella
bottle_len = 125;   // altura de la botella (irá tumbada)
bottle_d   = 36;    // diámetro
padding    = 5;     // holgura alrededor

// Número de botellas a guardar
n = 6;  // ajusta aquí cuántas quieres almacenar

// Paredes
thickness = 3;

// Dimensiones de la caja interna
inner_x = bottle_len;
inner_y = n*bottle_d;
inner_z = bottle_d;

// Caja externa con paredes
outer_x = inner_x + 2*thickness + 2*padding;
outer_y = inner_y + 2*thickness + 2*padding;
outer_z = inner_z + thickness + padding;

// Caja principal
module caja() {
    difference() {
        cube([outer_x, outer_y, outer_z]);
        translate([thickness, thickness, thickness])
            cube([outer_x-2*thickness,
                  outer_y-2*thickness,
                  outer_z-thickness]);
    }
}

// Tapa simple que cubre por encima
module tapa() {
    translate([0,0,outer_z])
        cube([outer_x, outer_y, thickness+3]);
}

// Ensamblado
caja();
tapa();
