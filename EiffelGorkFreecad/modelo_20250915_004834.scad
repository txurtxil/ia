// eiffel_tower.scad
// High-fidelity Eiffel Tower model in OpenSCAD
// Units: meters by default. Use scale(s) or unit_scale = 1000; to convert to mm for printing.

// -------------------------
// CONFIGURATION / PARAMETERS
// -------------------------
unit_scale = 1; // 1 = meters. Set to 0.001 for mm (for printing)

// Geometric outline
r_outer_0 = 62.5 * unit_scale; // half-side at base
w0 = 12.5 * unit_scale;        // half pillar width at base
h = 300 * unit_scale;          // structural height

// Platform heights
h1 = 57 * unit_scale;
h2 = 115 * unit_scale;
h3 = 276 * unit_scale;
h4 = h; // top

// Multi-stage taper ratios
ratio1 = 31.5 / 62.5;
ratio2 = 18.5 / 31.5;
ratio3 = 8 / 18.5;
ratio4 = 0.5 / 8;

// Visual / fidelity switches
DETAIL = "high"; // "high", "medium", "preview"

// Derived rendering parameters depending on DETAIL
SEGMENTS = (DETAIL == "high") ? 64 : (DETAIL == "medium") ? 32 : 12;
N = (DETAIL == "high") ? 200 : (DETAIL == "medium") ? 120 : 40;

// Beam sizes (scaled)
beam_diam = (DETAIL == "high") ? 0.45 * unit_scale : 0.5 * unit_scale;
brace_diam = (DETAIL == "high") ? 0.22 * unit_scale : 0.3 * unit_scale;
brace_every = (DETAIL == "high") ? 1 : (DETAIL == "medium") ? 2 : 4;

// Platform thickness
platform_thickness = 1.0 * unit_scale;

// Corners (four legs)
corners = [[1,1],[1,-1],[-1,-1],[-1,1]];

// -------------------------
// MATH / PROFILE FUNCTIONS
// -------------------------
function half_side(z) =
    (z <= h1) ? r_outer_0 * pow(ratio1, z / h1) :
    (z <= h2) ? 31.5 * unit_scale * pow(ratio2, (z - h1) / (h2 - h1)) :
    (z <= h3) ? 18.5 * unit_scale * pow(ratio3, (z - h2) / (h3 - h2)) :
                 8 * unit_scale * pow(ratio4, (z - h3) / (h4 - h3));

function w_leg_half(z) = w0 * (half_side(z) / (r_outer_0));
function r_leg_center(z) = half_side(z) - w_leg_half(z);

step = h / N;

// -------------------------
// PRIMITIVES / UTILITIES
// -------------------------
module line(p1, p2, diameter = beam_diam, segments = SEGMENTS) {
    dir = [p2[0]-p1[0], p2[1]-p1[1], p2[2]-p1[2]];
    len = norm(dir);
    if (len > 1e-9) {
        unit = dir / len;
        axis = cross([0,0,1], unit);
        angle = acos(unit.z);

        translate(p1)
            if (norm(axis) > 1e-9) {
                rotate(angle, axis)
                    translate([0,0,len/2])
                        cylinder(h=len, r=diameter/2, $fn=segments, center=true);
            } else {
                translate([0,0,len/2])
                    cylinder(h=len, r=diameter/2, $fn=segments, center=true);
            }
    }
}

module joint_sphere(pos, r = beam_diam*0.55, segments = SEGMENTS) {
    translate(pos) sphere(r=r, $fn=segments);
}

// -------------------------
// STRUCTURAL ELEMENTS
// -------------------------
module leg_beams() {
    for (corner = corners) {
        sx = corner[0];
        sy = corner[1];
        offsets = [[-1,-1],[-1,1],[1,-1],[1,1]];
        for (off = offsets) {
            dx = off[0];
            dy = off[1];
            for (i = [0 : N-1]) {
                z1 = i * step;
                z2 = (i+1) * step;
                p1 = [sx * (r_leg_center(z1) + dx * w_leg_half(z1)),
                      sy * (r_leg_center(z1) + dy * w_leg_half(z1)), z1];
                p2 = [sx * (r_leg_center(z2) + dx * w_leg_half(z2)),
                      sy * (r_leg_center(z2) + dy * w_leg_half(z2)), z2];
                line(p1, p2, beam_diam);
                if (DETAIL != "preview") joint_sphere(p1, beam_diam*0.55);
            }
            joint_sphere([sx * (r_leg_center(h) + dx * w_leg_half(h)),
                          sy * (r_leg_center(h) + dy * w_leg_half(h)), h],
                         beam_diam*0.55);
        }
    }
}

module leg_braces() {
    for (corner = corners) {
        sx = corner[0];
        sy = corner[1];
        for (i = [0 : brace_every : N]) {
            z = i * step;
            p00 = [sx * (r_leg_center(z) - w_leg_half(z)),
                   sy * (r_leg_center(z) - w_leg_half(z)), z];
            p01 = [sx * (r_leg_center(z) - w_leg_half(z)),
                   sy * (r_leg_center(z) + w_leg_half(z)), z];
            p10 = [sx * (r_leg_center(z) + w_leg_half(z)),
                   sy * (r_leg_center(z) - w_leg_half(z)), z];
            p11 = [sx * (r_leg_center(z) + w_leg_half(z)),
                   sy * (r_leg_center(z) + w_leg_half(z)), z];

            line(p00, p01, brace_diam);
            line(p01, p11, brace_diam);
            line(p11, p10, brace_diam);
            line(p10, p00, brace_diam);

            line(p00, p11, brace_diam);
            line(p01, p10, brace_diam);
        }
    }
}

module cross_leg_braces() {
    for (i = [0 : brace_every : N]) {
        z = i * step;
        inner_pts = [];
        for (corner = corners) {
            sx = corner[0];
            sy = corner[1];
            inner_pts = concat(inner_pts,
                               [[sx * (r_leg_center(z) - 0.5 * w_leg_half(z)),
                                 sy * (r_leg_center(z) - 0.5 * w_leg_half(z)), z]]);
        }
        for (j = [0 : len(inner_pts)-1]) {
            p1 = inner_pts[j];
            p2 = inner_pts[(j+1)%len(inner_pts)];
            pdiag = inner_pts[(j+2)%len(inner_pts)];
            line(p1, p2, brace_diam);
            line(p1, pdiag, brace_diam);
        }
    }
}

module platforms() {
    p1 = half_side(h1);
    p2 = half_side(h2);
    p3 = half_side(h3);

    translate([0,0,h1]) cube([2*p1, 2*p1, platform_thickness], center=true);
    translate([0,0,h2]) cube([2*p2, 2*p2, platform_thickness], center=true);
    translate([0,0,h3]) cube([2*p3, 2*p3, platform_thickness], center=true);
}

module spire() {
    antenna_h = 24 * unit_scale;
    translate([0,0,h])
        cylinder(h=antenna_h, r1=half_side(h), r2=0, $fn=SEGMENTS);
}

// -------------------------
// FINAL ASSEMBLY
// -------------------------
module eiffel_tower() {
    union() {
        leg_beams();
        leg_braces();
        cross_leg_braces();
        platforms();
        spire();
    }
}

eiffel_tower();
