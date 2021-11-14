module LxGame
  abstract class Game
    FPS_INTERVAL = 1.0

    property width : Int32
    property height : Int32
    property scale : Int32
    property title : String

    @fps_lasttime : Float64 = Time.monotonic.total_milliseconds # the last recorded time.
    @fps_current : UInt32 = 0                                   # the current FPS.
    @fps_frames : UInt32 = 0                                    # frames passed since the last recorded fps.
    @last_time : Float64 = Time.monotonic.total_milliseconds

    def initialize(@width, @height, @scale = 1, @title = self.class.name)
      SDL.init(SDL::Init::VIDEO)
      @window = SDL::Window.new(@title, @width * @scale, @height * @scale)
      @renderer = SDL::Renderer.new(@window, flags: SDL::Renderer::Flags::SOFTWARE)
      @renderer.scale = {@scale, @scale}
    end

    abstract def update(dt : Float64)
    abstract def draw

    def elapsed_time
      Time.monotonic.total_milliseconds
    end

    def engine_update
      @fps_frames += 1
      et = elapsed_time

      if @fps_lasttime < et - FPS_INTERVAL * 1000
        @fps_lasttime = et
        @fps_current = @fps_frames
        @fps_frames = 0
        @window.title = String.build { |io| io << @title << " - " << @fps_current << " fps" }
      end

      update((et - @last_time) / 1000.0)
      @last_time = et
    end

    def engine_draw
      draw
      @renderer.present
    end

    def run!
      loop do
        case event = SDL::Event.poll
        when SDL::Event::Keyboard
          if event.keydown?
            @controller.press(event.sym)
          elsif event.keyup?
            @controller.release(event.sym)
          end
        when SDL::Event::Quit
          break
        end

        engine_update
        engine_draw
      end
    ensure
      SDL.quit
    end
  end
end
