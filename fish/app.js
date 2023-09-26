import { default as seagulls } from './seagulls.js'
import { Pane } from 'https://cdn.jsdelivr.net/npm/tweakpane@4.0.1/dist/tweakpane.min.js'

const params = {
  num_particles: 1024,
  fish_size: 0.015,
  base_speed: 0.002,
  speed_variation: 0.005
}

const ui = new Pane();
const np = ui.addBinding(params,'num_particles',{
  min:0,
  max:2048,
  step:1
});
ui.addBinding(params,'fish_size',{
  min:0.0,
  max:0.05,
  step:0.001
});
const bs = ui.addBinding(params,'base_speed',{
  min:0.0,
  max:0.01,
  step:0.0001
});
const sv = ui.addBinding(params,'speed_variation',{
  min:0.0,
  max:0.01,
  step:0.0001
});

np.on('change', render)
bs.on('change', render)
sv.on('change', render)

async function render() {
  const WORKGROUP_SIZE = 8

  const sg = await seagulls.init(),
        render_shader  = await seagulls.import( './render.wgsl' ),
        compute_shader = await seagulls.import( './compute.wgsl' )

  const NUM_PARTICLES = params.num_particles, 
        // must be evenly divisble by 4 to use wgsl structs
        NUM_PROPERTIES = 4, 
        state = new Float32Array( params.num_particles * NUM_PROPERTIES )

  for( let i = 0; i < params.num_particles * NUM_PROPERTIES; i+= NUM_PROPERTIES ) {
    state[ i ] = -1 + Math.random() * 2
    state[ i + 1 ] = -1 + Math.random() * 2
    state[ i + 2 ] = Math.random() * params.speed_variation + params.base_speed
    state[ i + 3 ] = Math.random() * Math.PI * 2
  }

  sg.buffers({ state })
    .backbuffer( false )
    .blend( true )
    .uniforms({ num_particles: params.num_particles, fish_size: params.fish_size, res:[sg.width, sg.height ] })
    .onframe(() => {
      sg.uniforms.fish_size = params.fish_size
    })
    .compute( compute_shader, NUM_PARTICLES / (WORKGROUP_SIZE*WORKGROUP_SIZE) )
    .render( render_shader )
    .run( NUM_PARTICLES )
}

render()