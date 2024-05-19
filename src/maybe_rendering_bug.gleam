import gleam/int
import gleam/io
import gleam/result
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element
import lustre/element/html
import lustre/event
import tardis

pub fn main() {
  let assert Ok(main) = tardis.single("main")

  let app = lustre.application(init, update, view)

  let assert Ok(_) =
    app
    |> tardis.wrap(with: main)
    |> lustre.start("#app", Nil)
    |> tardis.activate(with: main)

  Nil
}

// Model
//
//

type Ctx {
  CtxReady(CanvasContext)
  CtxNeedsInit
  CtxError(String)
}

type Model {
  Model(ctx: Ctx, rect_x: Int)
}

fn default_model() -> Model {
  Model(CtxNeedsInit, rect_x: 10)
}

fn init(_: Nil) -> #(Model, Effect(Msg)) {
  #(default_model(), effect.none())
}

// View
//
//

fn view(model: Model) -> element.Element(Msg) {
  let title = html.h1([], [html.text("Hello, Canvas!")])

  let canvas = html.canvas([attribute.id("canvas"), attribute.width(500)])

  let x_input =
    html.div([], [
      html.div([], [
        html.label([attribute.for("x_input")], [html.text("x")]),
        html.input([
          event.on_input(fn(s) {
            let assert Ok(x) = int.parse(s)
            UserChangedRectX(x)
          }),
          attribute.id("x_input"),
          attribute.name("x_input"),
          attribute.type_("range"),
          attribute.min("10"),
          attribute.max(int.to_string(490)),
          attribute.value(int.to_string(model.rect_x)),
          attribute.step("10"),
        ]),
      ]),
    ])

  let draw_rect =
    html.div([], [
      html.button([event.on_click(UserClickedDrawRectagle)], [
        html.text("draw rectagle"),
      ]),
    ])

  html.div([], [title, canvas, x_input, draw_rect])
}

// Update
//
//

type Msg {
  DoNothing
  GetCanvasContext
  SetCanvasContext(Ctx)
  UserChangedRectX(Int)
  UserClickedDrawRectagle
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    DoNothing -> #(model, effect.none())
    GetCanvasContext -> #(model, get_canvas_context("canvas"))
    SetCanvasContext(ctx) -> {
      #(Model(..model, ctx: ctx), effect.none())
    }
    UserChangedRectX(x) -> #(Model(..model, rect_x: x), effect.none())
    UserClickedDrawRectagle -> #(model, draw_rect(model.ctx, model.rect_x))
  }
}

fn get_canvas_context(id: String) -> Effect(Msg) {
  use dispatch <- effect.from()

  let ctx = {
    use canvas <- result.try(document_get_element_by_id(id))
    use ctx <- result.map(canvas_get_context_2d(canvas))

    ctx
  }

  case ctx {
    Ok(ctx) -> CtxReady(ctx)
    Error(msg) -> CtxError(msg)
  }
  |> SetCanvasContext
  |> dispatch
}

fn draw_rect(ctx: Ctx, x: Int) -> Effect(Msg) {
  use dispatch <- effect.from()

  case ctx {
    CtxReady(ctx) -> {
      let _ = context_fill_rect(ctx, x: x, y: 10, width: 50, height: 50)

      dispatch(DoNothing)
    }
    CtxNeedsInit -> {
      dispatch(GetCanvasContext)
      dispatch(UserClickedDrawRectagle)
    }
    CtxError(error) -> {
      io.println_error("there was some error: " <> error)
      dispatch(DoNothing)
    }
  }
}

// FFI
// 
// 

type BrowserElement

type CanvasContext

@external(javascript, "./maybe_rendering_bug_ffi.mjs", "document_get_element_by_id")
fn document_get_element_by_id(id: String) -> Result(BrowserElement, String)

@external(javascript, "./maybe_rendering_bug_ffi.mjs", "canvas_get_context_2d")
fn canvas_get_context_2d(
  canvas: BrowserElement,
) -> Result(CanvasContext, String)

@external(javascript, "./maybe_rendering_bug_ffi.mjs", "context_fill_rect")
fn context_fill_rect(
  ctx: CanvasContext,
  x x: Int,
  y y: Int,
  width width: Int,
  height height: Int,
) -> CanvasContext
