struct Vant {
  pos: vec2f,
  dir: f32,
  flag: f32
}

@group(0) @binding(0) var<uniform> grid_size: f32;
@group(0) @binding(1) var<uniform> res: vec2f;
@group(0) @binding(2) var<uniform> blast_radius: f32;
@group(0) @binding(3) var<storage, read_write> vants: array<Vant>;
@group(0) @binding(4) var<storage, read_write> pheromones: array<f32>;
@group(0) @binding(5) var<storage, read_write> render: array<f32>;

const WORKGROUP_SIZE = 4;

fn vantIndex( cell:vec3u ) -> u32 {
  let size = u32(WORKGROUP_SIZE);
  return cell.x + (cell.y * size); 
}

fn pheromoneIndex( vant_pos: vec2f ) -> u32 {
  let width = round(res.x / grid_size);
  return u32(abs(vant_pos.y) * width + vant_pos.x);
}

@compute @workgroup_size(WORKGROUP_SIZE, WORKGROUP_SIZE, 1)

fn cs(@builtin(global_invocation_id) cell:vec3u)  {
  let field = round(res / grid_size);

  let pi2 = 6.283185;
  let index = vantIndex( cell );
  var vant:Vant = vants[ index ];

  let pIndex    = pheromoneIndex( vant.pos );
  let pheromone = pheromones[ pIndex ];

  if (vant.flag == 0.) {
    if (pheromone != 0.) {
      vant.dir += .25;
      pheromones[ pIndex ] = 0.;
    } else {
      vant.dir -= .25;
      pheromones[ pIndex ] = 1.;
    }
  } else if (vant.flag == 1.) {
    if (pheromone != 0.) {
      vant.dir -= .25;
      pheromones[ pIndex ] = 0.;
    } else {
      vant.dir += .25; // turn clockwise
      pheromones[ pIndex ] = 1.;
    }
  } else if (vant.flag == 2.) {
    if (pheromone != 0.) {
      vant.dir -= .25;
      // destroy pheromones in a given radius
      for (var y = 0.; y < field.y; y+= 1.) {
        for (var x = 0.; x < field.x; x+= 1.) {
          let pos = vec2(x, y);
          let norm_vant_pos = vec2f(vant.pos.x, vant.pos.y);
          if (distance(norm_vant_pos, pos) < blast_radius) {
            pheromones[pheromoneIndex(pos)] = 0.0;
          }
        }
      } 
    } else {
      pheromones[ pIndex ] = 1.;
    }
  }
  
  // calculate direction based on vant heading
  let dir = vec2f( cos( vant.dir * pi2 ), sin( vant.dir * pi2 ) );
  
  vant.pos = round( vant.pos + dir ) % field;
  if (vant.pos.x < 0.) { vant.pos.x = field.x - 1.; }
  if (vant.pos.y < 0.) { vant.pos.y = field.y - 1.; }

  vants[ index ] = vant;
  render[ pIndex ] = vant.flag + 1.;
}