import { Ok, Error } from "./gleam.mjs";

export function document_get_element_by_id(id) {
  let el = document.getElementById(id);

  return el === null ? new Error(`no element with id ${id}`) : new Ok(el);
}

export function canvas_get_context_2d(canvas) {
  if (canvas.getContext) {
    let ctx = canvas.getContext("2d");
    return new Ok(ctx);
  } else {
    return new Error("canvas is not supported");
  }
}

export function context_fill_rect(ctx, x, y, width, height) {
  requestAnimationFrame(() => {
    ctx.fillRect(x, y, width, height);
  })

  return ctx;
}
