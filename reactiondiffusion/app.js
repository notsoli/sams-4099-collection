import { default as seagulls } from './seagulls.js'
import {Pane} from 'https://cdn.jsdelivr.net/npm/tweakpane@4.0.1/dist/tweakpane.min.js';

const params = {
  time_since_click : 1,
  D_A : 1.0,
  D_B : 0.5,
  F : 0.055,
  K : 0.062
}

const ui = new Pane();
ui.addBinding(params,'D_A',{
  min:0.0,
  max:2.0,
  step:0.001
});
ui.addBinding(params,'D_B',{
  min:0.0,
  max:2.0,
  step:0.001
});
ui.addBinding(params,'F',{
  min:0.0,
  max:0.2,
  step:0.001
});
ui.addBinding(params,'K',{
  min:0.0,
  max:0.1,
  step:0.001
});

const sg = await seagulls.init(),
      frag = await seagulls.import('./frag.wgsl'),
      compute = await seagulls.import('./compute.wgsl'),
      render = seagulls.constants.vertex + frag,
      size = window.innerWidth * window.innerHeight,
      a = new Float32Array(size),
      b = new Float32Array(size)

for (let i = 0; i < size; i++) { a[i] = 1;}

document.onclick = (event) => {
  sg.uniforms.mouse_pos = [ event.clientX, event.clientY ];
  params.time_since_click = 0;
  document.querySelector("#instructions").style.display = "none";
}

sg.buffers({ a_in: a, a_out: a, b_in: b, b_out: b })
  .uniforms({ resolution:[window.innerWidth, window.innerHeight],
    mouse_pos: [window.innerWidth / 2, window.innerHeight / 2], time_since_click: 0.,
    D_A: params.D_A, D_B: params.D_B, F: params.F, K: params.K })
  .onframe(() => { 
    sg.uniforms.time_since_click = params.time_since_click++;
    sg.uniforms.D_A = params.D_A;
    sg.uniforms.D_B = params.D_B;
    sg.uniforms.F = params.F;
    sg.uniforms.K = params.K;
  })
  .backbuffer(false)
  .pingpong(64)
  .compute(
    compute,
    [Math.round(window.innerWidth / 8), Math.round(window.innerHeight / 8), 1], 
    {pingpong: ['a_in', 'b_in']}
  )
  .render(render)
  .run()