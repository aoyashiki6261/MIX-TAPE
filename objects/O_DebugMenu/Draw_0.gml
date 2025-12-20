draw_set_font(Fnt_DebugMenu);
draw_set_color(c_white);

var base_x = 10;
var base_y = 100;

for (var i = 0; i < menu_count; i++) {
    draw_set_color(i == menu_index ? c_yellow : c_white);
    draw_text(base_x, base_y + i * 30, menu_items[i]);
}
