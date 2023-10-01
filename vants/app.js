import { default as seagulls } from './seagulls.js'
import {Pane} from 'https://cdn.jsdelivr.net/npm/tweakpane@4.0.1/dist/tweakpane.min.js';

const params = {blast_radius: 3}
const ui = new Pane();
ui.addBinding(params, 'blast_radius',{
  min:0,
  max: 10,
  step: 0.5
});

const GRID_SIZE = 16,
      NUM_AGENTS = 16

const W = Math.round( window.innerWidth  / GRID_SIZE ),
      H = Math.round( window.innerHeight / GRID_SIZE )

let blast_radius = 3
 
const NUM_PROPERTIES = 4 // must be evenly divisble by 4!
const pheromones   = new Float32Array( W*H ) // hold pheromone data
const vants_render = new Float32Array( W*H ) // hold info to help draw vants
const vants        = new Float32Array( NUM_AGENTS * NUM_PROPERTIES ) // hold vant info

for( let i = 0; i < NUM_AGENTS * NUM_PROPERTIES; i+= NUM_PROPERTIES ) {
  vants[ i ]   = Math.floor( Math.random() * W )
  vants[ i+1 ] = Math.floor( Math.random() * H )
  vants[ i+2 ] = Math.floor( Math.random() * 4) / 4 // this is used to hold direction
  vants[ i+3 ] = Math.floor( Math.random() * 3) // vant type (flag)
}
const sg = await seagulls.init(),
  frag = await seagulls.import('./frag.wgsl'),
  render_shader = seagulls.constants.vertex + frag,
  compute_shader = await seagulls.import( './compute.wgsl' )

sg.uniforms({grid_size : GRID_SIZE, res : [window.innerWidth, window.innerHeight], blast_radius : 3})
  .buffers({ vants, pheromones, vants_render })
  .backbuffer( false )
  .compute( compute_shader, 1 )
  .render( render_shader )
  .onframe(() => {
    sg.buffers.vants_render.clear()
    sg.uniforms.blast_radius = params.blast_radius
  })
  .run( 1, 100 )