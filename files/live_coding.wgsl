// PRESS CTRL+ENTER TO RELOAD SHADER
// reference at https://github.com/charlieroberts/wgsl_live
@fragment 
fn fs( @builtin(position) pos : vec4f ) -> @location(0) vec4f {
  // get normalized texture coordinates (aka uv) in range 0-1
  let npos  = uvN( pos.xy );
  var grid_base = npos * 15.;
  grid_base.y *= res.y/res.x;

  // CHANGE
  grid_base.x += frame/100.;
  grid_base.y -= frame/100.;

  
  var grid = fract(grid_base);
  let grid_pos = floor(grid_base);

  var grid_width = audio[2];

  // CHANGE
  grid_width *= sin((grid_pos.x + grid_pos.y) / 2 + frame / 20) / 2 + 0.5;

  
  grid_width += 0.02;
  grid.x = step(grid_width, grid.x) * step(grid_width, 1-grid.x);
  grid.y = step(grid_width, grid.y) * step(grid_width, 1-grid.y);
  let grid_mask = 1 - grid.x*grid.y;

  var lasers = 0.;
  var counter = 0.;

  for (var i = 0; i < 5; i++) {
    counter += 1.;
    var lpos : vec2f = npos;
    lpos = rotate(lpos, counter*0.5);
    lpos.y += sin( lpos.x * (2. + counter*0.5) + (frame/(60. + counter * 40) + counter/5) * 4. ) * 0.2 - .5; 
    var lc = abs( (audio[2] / 20.) / lpos.y );
    lc = step(0.3, lc);
    lasers += lc;
  }

  // CHANGE
  // lasers = 0;

  var noise_pos = npos * 3;
  noise_pos.x += frame/150;
  noise_pos.y += frame/100;
  let perlin = perlin3(vec3(noise_pos, sin(frame/60.) * 0.5 + 0.5));


  var c1 = vec3(0.988,0.404,0.404);
  var c2 = vec3(0.925,0.,0.549);
  var c3 = vec3(1.);

  // var c1 = vec3(0.925,0.,0.549);;
  // var c2 = vec3(0.925,0.,0.549);
  // var c3 = vec3(1.);

  let color_data = step(0.5, grid_mask+lasers);
  var color = c3;

  if (color_data > 0.5) { color = mix(c1, c2, perlin); }
  
  // return vec4f( vec3((grid_mask + lasers) * perlin) , 1.);
  return vec4f(color, 1.);
  // return vec4f( vec3(lc), 1.);
  
}