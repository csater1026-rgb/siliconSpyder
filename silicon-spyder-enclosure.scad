// ============================================================================
// Silicon Spyder — Secure WiFi Box Enclosure
// Parametric case, split by physical layer:
//   BASE       (bottom)  — everything except the fans and the router: Pi4,
//                          SIM7600G-H HAT, Alfa/MT7921 monitor adapter.
//   CHAMBER    (middle)  — the 2x cooling fans.
//   TOP_FIXED  (top)     — the router's cradle walls + the front ~70% of its
//                          lid. Screwed down through all 4 corner posts;
//                          not meant to come off routinely.
//   TOP_HATCH  (top)     — a separate drop-in panel over the router's REAR
//                          ~30%, where its antennas AND its port cluster
//                          (WAN/LAN/power) actually are. Rests loose on top
//                          of the cradle walls (no screws) — lift it off by
//                          hand any time you need to plug/unplug the router
//                          or route a cable down the rear cable chase to the
//                          base, without touching the rest of the case.
// Non-metal only — this is meant to be 3D-printed (PETG or ABS recommended
// over PLA for the heat near the router/fans). Metal blocks WiFi.
//
// HOW TO USE: set `part` below to the piece you want, then render (F6) and
// export as STL (F7 in the OpenSCAD GUI, or see the command-line examples
// at the bottom of this file). Print one part at a time.
//
// Units: mm throughout.
// ============================================================================

part = "all"; // "base" | "chamber" | "top_fixed" | "top_hatch" | "all" (all = assembly preview only, do not print "all")

/* [Router — TP-Link Archer AX21 (AX1800)] */
router_w = 261;   // long axis
router_d = 135;
router_h = 39;

/* [Footprint geometry] */
// The router's long (261mm) sides are cradled snugly by thin walls.
// The router's 135mm depth is shorter than the module, so front/back voids
// are left over — those voids are the internal cable chase (router power +
// Ethernet routed straight down to the Pi) and the carry-handle cutouts.
cradle_wall  = 6;     // wall hugging the router's long sides
side_void    = 22.5;  // front/back void depth (cable chase + handles)

footprint_w = router_w + 2*cradle_wall;  // = 273mm, matches the brief's target footprint
footprint_d = router_d + 2*side_void;    // = 180mm, matches the brief's target footprint
// NOTE: 22.5mm of void is what actually makes the cable chase + handle
// cutouts functional (enough room for an RJ45 + DC barrel plug side by
// side). A tighter void looks fine on paper but won't fit real cables.

/* [Shared shell] */
wall_t  = 3;     // wall thickness (2-3 perimeters on most FDM printers)
floor_t = 3;

/* [Corner posts — one M3 screw runs through all 3 parts into a captured nut in the base] */
post_d      = 9;      // corner post outer diameter
screw_d     = 3.4;    // M3 clearance hole (through top + chamber + base)
post_inset  = 8;       // post center inset from each footprint edge
m3_nut_af   = 5.6;     // M3 hex nut across-flats, +clearance
m3_nut_h    = 2.8;     // M3 hex nut thickness, +clearance

/* [Layer heights] */
base_h       = 45;              // bottom: clears Pi4 + SIM7600G-H HAT stack + antenna connectors
chamber_h    = 30;               // middle: fans
top_wall_h   = router_h + 4;     // top: cradle walls, snug over the router's 39mm height
top_lid_t    = 3;                // top: lid thickness, on top of the cradle walls
top_h        = top_wall_h + top_lid_t;

/* [Venting] */
vent_w        = 4;     // slot width
vent_len_frac = 0.7;    // fraction of a wall's length used for its vent field, centered

/* [Fans — 2x 40mm, mounted in the chamber floor blowing upward] */
fan_size         = 40;
fan_hole_pattern = 32;
fan_bore         = 38;
fan_count        = 2;
fan_screw_d      = 3.2;

/* [Raspberry Pi 4 — real board 85x56mm, M2.5 holes on a 58x49mm pattern] */
// (The Pi4's own WiFi/Bluetooth antenna is an onboard PCB trace with no
// external connector, so it needs no panel-mount hole — just non-metal walls.)
pi_w             = 85;
pi_d             = 56;
pi_hole_dx       = 58;
pi_hole_dy       = 49;
pi_hole_inset_x  = 3.5;   // hole inset from board edge (both axes)
pi_standoff_d    = 6;
pi_standoff_h    = 8;      // clears the underside of the board + any bottom components
pi_mount_hole_d  = 2.6;    // self-taps for M2.5

/* [Antenna panel mounts — base's short end walls] */
// Full antenna audit across every powered part in the system:
//   Raspberry Pi 4 ................ 0 (onboard PCB antenna, no external connector)
//   SIM7600G-H 4G HAT ............. 2 ship in the box: LTE MAIN + GPS/GNSS.
//                                    The board also has a 3rd, unpopulated
//                                    AUX/diversity pad — a labeled spare hole
//                                    is included below in case you add one.
//   Alfa/MT7921 monitor adapter ... 2 (confirmed against the actual hardware)
//   TP-Link Archer AX21 ........... 4, fixed to the router body (not
//                                    removable/upgradable, not fold-flat —
//                                    handled in TOP below, not here)
//   YEREADW power meter ........... 0
//   ALLWEI power station ........... 0
// So the base needs 5 real SMA bulkhead holes (4 active + 1 labeled spare).
sma_hole_d = 6.5;

// Left end wall (x=0): SIM7600G-H HAT
hat_sma_positions = [
  [footprint_d * 0.24, base_h * 0.62],  // LTE MAIN
  [footprint_d * 0.50, base_h * 0.62],  // GPS / GNSS
  [footprint_d * 0.76, base_h * 0.62],  // spare — HAT's AUX/diversity pad (unpopulated by default)
];

// Right end wall (x=footprint_w): Alfa/MT7921 monitor adapter
alfa_sma_positions = [
  [footprint_d * 0.35, base_h * 0.62],
  [footprint_d * 0.65, base_h * 0.62],
];

/* [Router antenna clearance — TOP only] */
// The AX21's 4 antennas are fixed to the router body and rise from its REAR
// edge; they tilt for angle but don't fold flat. So the lid can't have plain
// closed holes there (you'd have to unscrew the antennas to ever lift the
// lid). Instead each antenna gets a slot that's open at the lid's rear edge:
// lifting the lid, then sliding it back slightly, clears the antennas
// without touching them. Positions are evenly-spaced placeholders — nudge
// antenna_xs to match your AX21's real antenna spacing once it's in hand.
antenna_slot_w = 16;   // wide enough for a screw-mount antenna's hinge base, not just its shaft
antenna_xs = [
  footprint_w * 0.20, footprint_w * 0.38,
  footprint_w * 0.62, footprint_w * 0.80,
];
// y where the router's rear edge (and so its antennas) sits, assuming the
// router is loaded with its antenna edge toward the footprint_d-max side
antenna_row_y = side_void + router_d;

/* [Rear access hatch — TOP_HATCH] */
// How far the hatch reaches forward past the router's rear edge, so it
// actually exposes the port row (WAN/LAN/power), not just empty void.
// Default 30mm: covers the full 22.5mm rear void plus ~30mm into the
// router's body — nudge this once you've measured how deep the AX21's
// port cluster sits from its rear face.
hatch_router_overlap = 30;
hatch_y_start = antenna_row_y - hatch_router_overlap;
hatch_depth   = footprint_d - hatch_y_start;
hatch_t       = 3;  // hatch thickness — rests on top of the cradle walls, flush with the fixed lid

$fn = 48;

// ============================================================================
// Helpers
// ============================================================================

function corner_positions() = [
  [post_inset, post_inset],
  [footprint_w - post_inset, post_inset],
  [post_inset, footprint_d - post_inset],
  [footprint_w - post_inset, footprint_d - post_inset],
];

// A corner post with a through-hole for the M3 assembly screw.
module corner_post(h) {
  difference() {
    cylinder(d = post_d, h = h);
    translate([0, 0, -0.5]) cylinder(d = screw_d, h = h + 1);
  }
}

module all_corner_posts(h) {
  for (p = corner_positions())
    translate([p[0], p[1], 0]) corner_post(h);
}

// Hex nut trap, opening downward from z=0 (used at the base's floor).
module nut_trap(h = m3_nut_h) {
  cylinder(d = m3_nut_af / cos(30), h = h, $fn = 6);
}

// A field of vertical slots cut along a wall of given length/height, meant to
// be translated+rotated into place by the caller. Slots run in Z, cut through Y.
module vent_field(wall_len, wall_h, n, z0 = 0) {
  usable = wall_len * vent_len_frac;
  start  = (wall_len - usable) / 2;
  pitch  = usable / n;
  slot_w = min(vent_w, pitch * 0.6);
  for (i = [0 : n - 1])
    translate([start + i * pitch + (pitch - slot_w) / 2, -1, z0])
      cube([slot_w, wall_t + 2, wall_h]);
}

// Generic open-top box shell: floor + 4 walls, wall thickness wall_t.
module shell(w, d, h, floor = true) {
  difference() {
    cube([w, d, h]);
    translate([wall_t, wall_t, floor ? floor_t : -1])
      cube([w - 2*wall_t, d - 2*wall_t, h - (floor ? floor_t : 0) + 1]);
  }
}

// ============================================================================
// BASE (bottom) — everything except the fans and the router: Pi4,
// SIM7600G-H HAT, Alfa/MT7921 monitor adapter. Closed, vented box. Nut traps
// at the 4 corner posts capture the single M3 assembly screw that runs up
// through chamber + top.
// ============================================================================
module base() {
  difference() {
    union() {
      shell(footprint_w, footprint_d, base_h);
      all_corner_posts(base_h);
    }

    // Intake venting on both long (front/back) walls, low down near the floor
    translate([0, 0, 0])
      vent_field(footprint_w, base_h * 0.5, 10, z0 = floor_t + 4);
    translate([0, footprint_d - wall_t, 0])
      vent_field(footprint_w, base_h * 0.5, 10, z0 = floor_t + 4);

    // SMA panel-mount holes — see the antenna audit above. HAT on the left
    // end wall, Alfa adapter on the right end wall.
    for (yz = hat_sma_positions)
      translate([-1, yz[0], yz[1]])
        rotate([0, 90, 0])
          cylinder(d = sma_hole_d, h = wall_t + 2);
    for (yz = alfa_sma_positions)
      translate([footprint_w - wall_t - 1, yz[0], yz[1]])
        rotate([0, 90, 0])
          cylinder(d = sma_hole_d, h = wall_t + 2);

    // Nut traps for the assembly screws, opening from the floor underside
    for (p = corner_positions())
      translate([p[0], p[1], -0.5]) nut_trap();
  }

  // Pi4 mounting standoffs — real 58x49mm hole pattern, centered in the base
  pi_origin = [(footprint_w - pi_w)/2, (footprint_d - pi_d)/2];
  for (hx = [pi_hole_inset_x, pi_hole_inset_x + pi_hole_dx])
    for (hy = [pi_hole_inset_x, pi_hole_inset_x + pi_hole_dy])
      translate([pi_origin[0] + hx, pi_origin[1] + hy, floor_t])
        difference() {
          cylinder(d = pi_standoff_d, h = pi_standoff_h);
          translate([0, 0, -0.5]) cylinder(d = pi_mount_hole_d, h = pi_standoff_h + 1);
        }
}

// ============================================================================
// CHAMBER (middle) — the 2x cooling fans.
// Fully enclosed except vents on both long walls; fans mounted in a solid
// floor shelf, blowing upward (pulling intake air from the base below and
// the side vents, exhausting up through the open-bottom top piece and out
// its vented lid). Top and bottom of the side walls are open — the corner
// posts + adjoining parts close the box.
// ============================================================================
module chamber() {
  difference() {
    union() {
      // side walls only (no ceiling plate — open top)
      difference() {
        cube([footprint_w, footprint_d, chamber_h]);
        translate([wall_t, wall_t, -1])
          cube([footprint_w - 2*wall_t, footprint_d - 2*wall_t, chamber_h + 2]);
      }
      all_corner_posts(chamber_h);

      // solid fan-mounting shelf, low in the chamber (fan bores + screw
      // holes are cut through it separately by chamber_fan_cuts())
      cube([footprint_w, footprint_d, floor_t]);
    }

    // vents on both long walls, upper half (above the fan shelf)
    translate([0, 0, 0])
      vent_field(footprint_w, chamber_h * 0.6, 10, z0 = floor_t + 6);
    translate([0, footprint_d - wall_t, 0])
      vent_field(footprint_w, chamber_h * 0.6, 10, z0 = floor_t + 6);
  }
}

module chamber_fan_cuts() {
  fan_y  = footprint_d / 2;
  fan_xs = fan_count == 2
    ? [footprint_w/2 - fan_size*0.6, footprint_w/2 + fan_size*0.6]
    : [footprint_w/2];
  for (fx = fan_xs) {
    translate([fx, fan_y, -0.5]) cylinder(d = fan_bore, h = floor_t + 2);
    for (cxy = [[1,1], [1,-1], [-1,1], [-1,-1]])
      translate([fx + cxy[0]*fan_hole_pattern/2, fan_y + cxy[1]*fan_hole_pattern/2, -0.5])
        cylinder(d = fan_screw_d, h = floor_t + 2);
  }
}

// ============================================================================
// TOP_FIXED — cradle walls (full depth) + the front lid, covering the router
// from y=0 to hatch_y_start. Screwed down through all 4 corner posts, same
// as base/chamber; this is the part that stays put. Drops down over the
// router from above (open bottom, so it slides over the router sitting on
// the chamber below, and the router's underside stays open to the chamber's
// airflow). The rear (hatch_y_start to footprint_d) is deliberately left
// open on top here — TOP_HATCH covers it separately.
// ============================================================================
module top_fixed() {
  handle_w = 70;
  handle_h = 14;

  difference() {
    union() {
      // cradle walls on the router's long sides — full depth, so the hatch
      // has continuous wall-top to rest on all the way to the rear edge
      translate([0, 0, 0]) cube([cradle_wall, footprint_d, top_wall_h]);
      translate([footprint_w - cradle_wall, 0, 0]) cube([cradle_wall, footprint_d, top_wall_h]);

      // thin front lip — closes the front void mostly, minus its handle cutout
      translate([0, 0, 0]) cube([footprint_w, wall_t, top_wall_h]);

      all_corner_posts(top_h);

      // front lid only — from the front edge to where the hatch takes over
      translate([0, 0, top_wall_h]) cube([footprint_w, hatch_y_start, top_lid_t]);
    }

    // carry-handle cutout in the front void (the only load-bearing carry
    // point up here — the rear hatch rests loose, don't lift the box by it)
    translate([footprint_w/2 - handle_w/2, -1, top_wall_h/2 - handle_h/2])
      cube([handle_w, side_void + wall_t + 2, handle_h]);

    // front lid vents, two rows over the router body
    for (yfrac = [0.28, 0.55])
      translate([0, footprint_d * yfrac - vent_w/2, top_wall_h - 0.5])
        for (i = [0:14])
          translate([footprint_w*0.08 + i*(footprint_w*0.84/15), 0, 0])
            cube([footprint_w*0.84/15*0.5, vent_w, top_lid_t + 1]);

    // corner screw holes (front 2 posts go through the lid; rear 2 posts
    // are already open-topped since the lid doesn't reach back that far)
    for (p = corner_positions())
      translate([p[0], p[1], top_wall_h - 0.5]) cylinder(d = screw_d, h = top_lid_t + 1);
  }
}

// ============================================================================
// TOP_HATCH — the detachable rear access panel. Rests loose on top of
// top_fixed's cradle walls (z = top_wall_h to top_wall_h+hatch_t, flush with
// the front lid's top surface) spanning the rear hatch_depth zone — no
// screws, just lift it off by hand. This is where the router's antennas
// AND its port cluster (WAN/LAN/power) actually are, and where cables drop
// down the rear cable chase to the base.
//
// REMOVAL: the AX21's antennas are fixed and don't fold flat, so a plain
// closed hole would mean unscrewing antennas just to lift this off. Instead
// each antenna gets a slot closed near the router body but open straight
// through the hatch's rear edge — lift up and slide slightly toward the
// rear as you go, and the antennas slide out the open ends untouched.
// Corner-post clearance notches let it drop in around the rear 2 posts.
// ============================================================================
module top_hatch() {
  difference() {
    // spans between the cradle walls (rests on their top faces) and the
    // full hatch_depth back to the rear edge
    translate([cradle_wall, hatch_y_start, 0])
      cube([footprint_w - 2*cradle_wall, hatch_depth, hatch_t]);

    // clearance notches for the rear 2 corner posts, which poke up through
    // this zone regardless (they belong to top_fixed, not this piece)
    for (p = [corner_positions()[2], corner_positions()[3]])
      translate([p[0], p[1], -0.5]) cylinder(d = post_d + 1, h = hatch_t + 1);

    // vent slots — light venting near the front (router-body) edge of the hatch
    translate([0, hatch_y_start + 6, -0.5])
      for (i = [0:10])
        translate([footprint_w*0.10 + i*(footprint_w*0.80/11), 0, 0])
          cube([footprint_w*0.80/11*0.5, vent_w, hatch_t + 1]);

    // antenna slots — closed a few mm short of the router's rear edge, open
    // all the way through to the hatch's (and enclosure's) rear edge
    for (ax = antenna_xs)
      translate([ax - antenna_slot_w/2, antenna_row_y - 4, -0.5])
        cube([antenna_slot_w, footprint_d - (antenna_row_y - 4), hatch_t + 1]);
  }
}

// ============================================================================
// Assembly preview (NOT for printing — render one part at a time via `part`)
// ============================================================================
module assembly_preview() {
  color("SteelBlue") base();
  translate([0, 0, base_h]) difference() {
    color("LightSlateGray") chamber();
    chamber_fan_cuts();
  }
  translate([0, 0, base_h + chamber_h]) color("RoyalBlue") top_fixed();
  translate([0, 0, base_h + chamber_h + top_wall_h]) color("DeepSkyBlue") top_hatch();
}

// ============================================================================
// Dispatch
// ============================================================================
if (part == "base") base();
else if (part == "chamber") difference() { chamber(); chamber_fan_cuts(); }
else if (part == "top_fixed") top_fixed();
else if (part == "top_hatch") top_hatch();
else assembly_preview();

// ----------------------------------------------------------------------------
// Command-line export examples (from this directory):
//   openscad -D 'part="base"'      -o base.stl      silicon-spyder-enclosure.scad
//   openscad -D 'part="chamber"'   -o chamber.stl   silicon-spyder-enclosure.scad
//   openscad -D 'part="top_fixed"' -o top_fixed.stl silicon-spyder-enclosure.scad
//   openscad -D 'part="top_hatch"' -o top_hatch.stl silicon-spyder-enclosure.scad
// ----------------------------------------------------------------------------
