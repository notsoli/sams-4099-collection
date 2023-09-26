struct Particle {
  pos: vec2f,
  speed: f32,
  angle: f32
};

@group(0) @binding(0) var<uniform> _num_particles: f32;
@group(0) @binding(2) var<uniform> res: vec2f;
@group(0) @binding(3) var<storage, read_write> state: array<Particle>;

const NUM_PROPERTIES = 4;

const AVOID_WEIGHT = 0.03;
const ATTRACT_WEIGHT = 0.05;

const AVOID_RADIUS = 0.2;
const ATTRACT_RADIUS = 0.4;

fn cellindex( cell:vec3u ) -> u32 {
  let size = 8u;
  return cell.x + (cell.y * size) + (cell.z * size * size);
}

@compute
@workgroup_size(8,8)

fn cs(@builtin(global_invocation_id) cell:vec3u)  {
  let num_particles = u32(_num_particles);
  
  let idx = cellindex( cell );
  let p = state[ idx ];

  var n_attract = 0.;
  var a_attract = 0.;
  var n_avoid = 0.;
  var a_avoid = 0.;

  for (var i : u32 = 0; i < num_particles * NUM_PROPERTIES; i += NUM_PROPERTIES) {
    if (i == idx) { continue; }

    let q = state[i];

    let dist = distance(p.pos, q.pos);
  
    if (dist >= ATTRACT_RADIUS) { continue; }

    let angle = atan2(p.pos.y - q.pos.y, p.pos.x - q.pos.x) + 3.1415;
    if (dist < AVOID_RADIUS) {
      // avoidance range
      n_avoid += 1.;
      a_avoid += angle - p.angle;
    } else if (dist < ATTRACT_RADIUS) {
      // attraction range
      n_attract += 1.;
      a_attract += angle - p.angle;
    }
  }

  if (n_attract > 0.5) {
    state[idx].angle += a_attract / n_attract * ATTRACT_WEIGHT;
  }
  if (n_avoid > 0.5) {
    state[idx].angle -= a_avoid / n_avoid * AVOID_WEIGHT;
  }

  var next = vec2(p.pos.x + p.speed * sin(p.angle), p.pos.y + p.speed * cos(p.angle));
  if (next.x < -1.) { next.x += 2.; }
  else if (next.x > 1.) { next.x -= 2.; }
  if (next.y < -1.) { next.y += 2.; }
  else if (next.y > 1.) { next.y -= 2.; }
  state[idx].pos = next;
}