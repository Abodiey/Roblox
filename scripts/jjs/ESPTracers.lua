local ESPTracers = {}

function ESPTracers.new(State, Assets)
    local enabled = State.Toggles.ESPTracers
    local getGradientColor = Assets.GetGradientColor
    local v2_new = Vector2.new
    local m_floor = math.floor

    local function Render(c, frame)
        if not enabled.Value then
            c.Line.Visible = false
            return
        end

        local sX = frame.tracerStartX
        local sY = frame.tracerStartY
        local root2D = frame.root2D
        local feet2D = frame.feet2D

        if frame.shouldUpdateHeavy then
            c.LineColor = getGradientColor(frame.dist / 600)
        end

                    -- Tracer
                    c.Line.Visible = true
                    c.Line.Color = c.LineColor
                    c.Line.From = v2_new(sX, sY)
                    c.Line.To = v2_new(m_floor(root2D.X), m_floor(feet2D.Y))
    end

    local function Hide(c)
        c.Line.Visible = false
    end

    return {
        Render = Render,
        Hide = Hide,
    }
end

return ESPTracers

