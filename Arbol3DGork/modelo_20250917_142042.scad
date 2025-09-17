module branch(length, thickness, angle, depth) {
    if (depth > 0) {
        cylinder(h = length, r1 = thickness, r2 = thickness * 0.6, $fn = 12);
        translate([0, 0, length]) {
            rotate([angle, 0, 0]) branch(length * 0.7, thickness * 0.7, angle * 1.1, depth - 1);
            rotate([-angle * 0.8, 0, 120]) branch(length * 0.7, thickness * 0.7, angle, depth - 1);
            rotate([angle * 0.5, 0, 240]) branch(length * 0.7, thickness * 0.7, angle * 1.2, depth - 1);
        }
    }
}

module tree() {
    // Tronco principal
    branch(20, 3, 25, 7);
    
    // Añadir algo de follaje simple para complejidad (esferas como hojas)
    for (i = [0:5:360]) {
        rotate([0, 0, i]) translate([0, 0, 15 + rand(i)*5]) sphere(r = 4 + rand(i)*2, $fn = 8);
    }
}

// Semilla para random (para variabilidad)
function rand(x) = rands(0, 1, 1, x)[0];

tree();
