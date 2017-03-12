; Сидеть на 8ом для тиков, на 9ом для клавы

.model tiny
.386 ; чтобы прыгать дальше с je

.data
    help_text db "Up       - ", 18h, 0ah
              db "Down     - ", 19h, 0ah
              db "Left     - ", 11h, 0ah
              db "Right    - ", 10h, 0ah
              db "Drop     - SPACE", 0ah
              db "Rotate   - Z", 0ah
              db "Speed    - +/-", 0ah
              db "New game - N", 0ah
              db "Stop     - S", 0ah
              db "Pause    - P", '$'

    speed_text db "SPEED:", '$'
    score_text db "SCORE:", '$'
    end_game_text db "YOU LOST !", '$'
    end_game_text_clean db "          ", '$'

    score db 0

    figure_1_time db 0
    figure_2_time db 0
    figure_3_time db 0
    figure_4_time db 0
    figure_5_time db 0
    figure_6_time db 0
    figure_7_time db 0
    figure_8_time db 0
    figure_9_time db 0
    figure_10_time db 0
    figure_11_time db 0

    extreme_check_flag db 0

    video_memory dw 0b800h

    cursor_pos_row db ?
    cursor_pos_col db ?

    random_num db ?

    buffer dw 3 dup('$')
    buffer_len dw 3

    row dw ? ; строка
    col dw ? ; позиция в строке
    color db ? ; db проще цвет передавать
    symbol db ? ; рисуемый символ
    symb_size dw 2 ; размер символа - dw для умножения
    row_size dw 80 ; размер строки

    check_cell_row dw ?
    check_cell_col dw ?

    drop_cell_color db ?
    dropped_cells dw ?

    start_pos_glass dw 26 ; начальная позиция левой стены
    top_pos_glass dw 3 ; начало стакана
    down_pos_glass dw 24 ; позиция дна
    depth_glass dw 21 ; глубина стакана
    width_glass dw 14 ; ширина стакана
    color_glass db 44h ; цвет стакана - db проще передавать

    ; Стартовая позиция падающей фигуры
    start_pos_row dw 3
    start_pos_col dw 38

    ; Текущая позиция фигуры
    current_row dw ?
    current_col dw ?

    current_figure db ?
    rotate_pos_figure db ?
    figure_poses db 1, 2, 3, 4
    poses_len db 4
    stop_rotate_flag db 0

    colors db 11h, 22h, 33h, 55h, 66h, 77h ; синий, зелёный, розовый, оранжевый, серый- db проще цвет передавать
    colors_len db 6 ; db для простого деления

    figures db 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
    figures_len db 11

    figure_next_text db "NEXT FIGURE:", '$'
    predicted_color db 11h
    predicted_figure_num db 1
    predicted_rotate_pos_figure db 1
    color_temp db ?
    figure_num_temp db ?
    rotate_pos_figure_temp db ?

    ; 0 - пустота, 1 - что-то есть, 2 - переход строки
    ; + 4 положения фигуры
    ; + массив с нужными смещениеми ячеек, чтобы щупать дно
    ; Вертим всегда по часовой, для текущей фигуры пишем будущее состояние, какие ячейки проверить

    ; FIGURES
        ; Первая фигура
        figure_1 db "1"
        length_mass_figure_1 dw 1
        figure_bottom_1 db 1, 0
        figure_bottom_length_1 dw 1
        figure_left_sides_1 db 0, -1
        figure_left_sides_length_1 dw 1
        figure_right_sides_1 db 0, 1
        figure_right_sides_length_1 dw 1
        figure_rotate_1 db ?
        figure_rotate_length_1 dw 0

        ; Вторая фигура
        figure_2_1 db "1", "1"
        length_mass_figure_2_1 dw 2
        figure_bottom_2_1 db 1, 0, 1, 1
        figure_bottom_length_2_1 dw 2
        figure_left_sides_2_1 db 0, -1
        figure_left_sides_length_2_1 dw 1
        figure_right_sides_2_1 db 0, 2
        figure_right_sides_length_2_1 dw 1
        figure_rotate_2_1 db 1, 0
        figure_rotate_length_2_1 dw 1

        figure_2_2 db "1", "2", "1"
        length_mass_figure_2_2 dw 3
        figure_bottom_2_2 db 2, 0
        figure_bottom_length_2_2 dw 1
        figure_left_sides_2_2 db 0, -1, 1, -1
        figure_left_sides_length_2_2 dw 2
        figure_right_sides_2_2 db 0, 1, 1, 1
        figure_right_sides_length_2_2 dw 2
        figure_rotate_2_2 db 0, 1
        figure_rotate_length_2_2 dw 1

        ; Третья фигура
        figure_3_1 db "1", "1", "1"
        length_mass_figure_3_1 dw 3
        figure_bottom_3_1 db 1, 0, 1, 1, 1, 2
        figure_bottom_length_3_1 dw 3
        figure_left_sides_3_1 db 0, -1
        figure_left_sides_length_3_1 dw 1
        figure_right_sides_3_1 db 0, 3
        figure_right_sides_length_3_1 dw 1
        figure_rotate_3_1 db 1, 0, 2, 0
        figure_rotate_length_3_1 dw 2

        figure_3_2 db "1", "2", "1", "2", "1"
        length_mass_figure_3_2 dw 5
        figure_bottom_3_2 db 3, 0
        figure_bottom_length_3_2 dw 1
        figure_left_sides_3_2 db 0, -1, 1, -1, 2, -1
        figure_left_sides_length_3_2 dw 3
        figure_right_sides_3_2 db 0, 1, 1, 1, 2, 1
        figure_right_sides_length_3_2 dw 3
        figure_rotate_3_2 db 0, 1, 0, 2
        figure_rotate_length_3_2 dw 2

        ; Четвёртая фигура
        figure_4_1 db "1", "1", "2", "1"
        length_mass_figure_4_1 dw 4
        figure_bottom_4_1 db 1, 1, 2, 0
        figure_bottom_length_4_1 dw 2
        figure_left_sides_4_1 db 0, -1, 1, -1
        figure_left_sides_length_4_1 dw 2
        figure_right_sides_4_1 db 0, 2, 1, 1
        figure_right_sides_length_4_1 dw 2
        figure_rotate_4_1 db 1, 1
        figure_rotate_length_4_1 dw 1

        figure_4_2 db "1", "1", "2", "0", "1"
        length_mass_figure_4_2 dw 5
        figure_bottom_4_2 db 1, 0, 2, 1
        figure_bottom_length_4_2 dw 2
        figure_left_sides_4_2 db 0, -1, 1, 0
        figure_left_sides_length_4_2 dw 2
        figure_right_sides_4_2 db 0, 2, 1, 2
        figure_right_sides_length_4_2 dw 2
        figure_rotate_4_2 db 1, 0
        figure_rotate_length_4_2 dw 1

        figure_4_3 db "0", "1", "2", "1", "1"
        length_mass_figure_4_3 dw 5
        figure_bottom_4_3 db 2, 0, 2, 1
        figure_bottom_length_4_3 dw 2
        figure_left_sides_4_3 db 0, 0, 1, -1
        figure_left_sides_length_4_3 dw 2
        figure_right_sides_4_3 db 0, 2, 1, 2
        figure_right_sides_length_4_3 dw 2
        figure_rotate_4_3 db 0, 0
        figure_rotate_length_4_3 dw 1

        figure_4_4 db "1", "0", "2", "1", "1"
        length_mass_figure_4_4 dw 5
        figure_bottom_4_4 db 2, 0, 2, 1
        figure_bottom_length_4_4 dw 2
        figure_left_sides_4_4 db 0, -1, 1, -1
        figure_left_sides_length_4_4 dw 2
        figure_right_sides_4_4 db 0, 1, 1, 2
        figure_right_sides_length_4_4 dw 2
        figure_rotate_4_4 db 0, 1
        figure_rotate_length_4_4 dw 1

        ; Пятая фигура
        figure_5_1 db "1", "1", "2", "1", "2", "1"
        length_mass_figure_5_1 dw 6
        figure_bottom_5_1 db 1, 1, 3, 0
        figure_bottom_length_5_1 dw 2
        figure_left_sides_5_1 db 0, -1, 1, -1, 2, -1
        figure_left_sides_length_5_1 dw 3
        figure_right_sides_5_1 db 0, 2, 1, 1, 2, 1
        figure_right_sides_length_5_1 dw 3
        figure_rotate_5_1 db 0, 2, 1, 2
        figure_rotate_length_5_1 dw 2

        figure_5_2 db "1", "1", "1", "2", "0", "0", "1"
        length_mass_figure_5_2 dw 7
        figure_bottom_5_2 db 1, 0, 1, 1, 2, 2
        figure_bottom_length_5_2 dw 3
        figure_left_sides_5_2 db 0, -1, 1, -1, 2, -1
        figure_left_sides_length_5_2 dw 3
        figure_right_sides_5_2 db 0, 3, 1, 3
        figure_right_sides_length_5_2 dw 2
        figure_rotate_5_2 db 2, 0, 2, 1
        figure_rotate_length_5_2 dw 2

        figure_5_3 db "0", "1", "2", "0", "1", "2", "1", "1"
        length_mass_figure_5_3 dw 8
        figure_bottom_5_3 db 3, 0, 3, 1
        figure_bottom_length_5_3 dw 2
        figure_left_sides_5_3 db 0, 0, 1, 0, 2, -1
        figure_left_sides_length_5_3 dw 3
        figure_right_sides_5_3 db 0, 2, 1, 2, 2, 2
        figure_right_sides_length_5_3 dw 3
        figure_rotate_5_3 db 0, 0, 1, 0, 1, 2
        figure_rotate_length_5_3 dw 3

        figure_5_4 db "1", "0", "0", "2", "1", "1", "1"
        length_mass_figure_5_4 dw 7
        figure_bottom_5_4 db 2, 0, 2, 1, 2, 2
        figure_bottom_length_5_4 dw 3
        figure_left_sides_5_4 db 0, -1, 1, -1
        figure_left_sides_length_5_4 dw 2
        figure_right_sides_5_4 db 0, 1, 1, 3
        figure_right_sides_length_5_4 dw 2
        figure_rotate_5_4 db 0, 1, 2, 0, 3, 0
        figure_rotate_length_5_4 dw 3

        ; Шестая фигура
        figure_6 db "1", "1", "2", "1", "1"
        length_mass_figure_6 dw 5
        figure_bottom_6 db 2, 0, 2, 1
        figure_bottom_length_6 dw 2
        figure_left_sides_6 db 0, -1, 1, -1
        figure_left_sides_length_6 dw 2
        figure_right_sides_6 db 0, 2, 1, 2
        figure_right_sides_length_6 dw 2
        figure_rotate_6 db ?
        figure_rotate_length_6 dw 0

        ; Седьмая фигура
        figure_7_1 db "1", "1", "2", "0", "1", "2", "0", "1"
        length_mass_figure_7_1 dw 8
        figure_bottom_7_1 db 1, 0, 3, 1
        figure_bottom_length_7_1 dw 2
        figure_left_sides_7_1 db 0, -1, 1, 0, 2, 0
        figure_left_sides_length_7_1 dw 3
        figure_right_sides_7_1 db 0, 2, 1, 2, 2, 2
        figure_right_sides_length_7_1 dw 3
        figure_rotate_7_1 db 0, 2, 1, 0, 1, 2
        figure_rotate_length_7_1 dw 3

        figure_7_2 db "0", "0", "1", "2", "1", "1", "1"
        length_mass_figure_7_2 dw 7
        figure_bottom_7_2 db 2, 0, 2, 1, 2, 2
        figure_bottom_length_7_2 dw 3
        figure_left_sides_7_2 db 1, -1, 0, 1
        figure_left_sides_length_7_2 dw 2
        figure_right_sides_7_2 db 0, 3, 1, 3
        figure_right_sides_length_7_2 dw 2
        figure_rotate_7_2 db 0, 0, 2, 0, 2, 1
        figure_rotate_length_7_2 dw 3

        figure_7_3 db "1", "0", "2", "1", "0", "2", "1", "1"
        length_mass_figure_7_3 dw 8
        figure_bottom_7_3 db 3, 0, 3, 1
        figure_bottom_length_7_3 dw 2
        figure_left_sides_7_3 db 0, -1, 1, -1, 2, -1
        figure_left_sides_length_7_3 dw 3
        figure_right_sides_7_3 db 0, 1, 1, 1, 2, 2
        figure_right_sides_length_7_3 dw 3
        figure_rotate_7_3 db 0, 1, 0, 2
        figure_rotate_length_7_3 dw 2

        figure_7_4 db "1", "1", "1", "2", "1", "0", "0"
        length_mass_figure_7_4 dw 7
        figure_bottom_7_4 db 2, 0, 1, 1, 1, 2
        figure_bottom_length_7_4 dw 3
        figure_left_sides_7_4 db 0, -1, 1, -1
        figure_left_sides_length_7_4 dw 2
        figure_right_sides_7_4 db 0, 3, 1, 1
        figure_right_sides_length_7_4 dw 2
        figure_rotate_7_4 db 1, 1, 2, 1
        figure_rotate_length_7_4 dw 2

        ; Восьмая фигура
        figure_8_1 db "0", "1", "2", "1", "1", "2", "0", "1"
        length_mass_figure_8_1 dw 8
        figure_bottom_8_1 db 2, 0, 3, 1
        figure_bottom_length_8_1 dw 2
        figure_left_sides_8_1 db 0, 0, 1, -1, 2, 0
        figure_left_sides_length_8_1 dw 3
        figure_right_sides_8_1 db 0, 2, 1, 2, 2, 2
        figure_right_sides_length_8_1 dw 3
        figure_rotate_8_1 db 1, 2
        figure_rotate_length_8_1 dw 1

        figure_8_2 db "0", "1", "0", "2", "1", "1", "1"
        length_mass_figure_8_2 dw 7
        figure_bottom_8_2 db 2, 0, 2, 1, 2, 2
        figure_bottom_length_8_2 dw 3
        figure_left_sides_8_2 db 0, 0, 1, -1
        figure_left_sides_length_8_2 dw 2
        figure_right_sides_8_2 db 0, 2, 1, 3
        figure_right_sides_length_8_2 dw 2
        figure_rotate_8_2 db 0, 0, 2, 0
        figure_rotate_length_8_2 dw 2

        figure_8_3 db "1", "0", "2", "1", "1", "2", "1", "0"
        length_mass_figure_8_3 dw 8
        figure_bottom_8_3 db 3, 0, 2, 1
        figure_bottom_length_8_3 dw 2
        figure_left_sides_8_3 db 0, -1, 1, -1, 2, -1
        figure_left_sides_length_8_3 dw 3
        figure_right_sides_8_3 db 0, 1, 1, 2, 2, 1
        figure_right_sides_length_8_3 dw 3
        figure_rotate_8_3 db 0, 1, 0, 2
        figure_rotate_length_8_3 dw 2

        figure_8_4 db "1", "1", "1", "2", "0", "1", "0"
        length_mass_figure_8_4 dw 7
        figure_bottom_8_4 db 1, 0, 1, 2, 2, 1
        figure_bottom_length_8_4 dw 3
        figure_left_sides_8_4 db 0, -1, 1, 0
        figure_left_sides_length_8_4 dw 2
        figure_right_sides_8_4 db 0, 3, 1, 2
        figure_right_sides_length_8_4 dw 2
        figure_rotate_8_4 db 1, 0, 2, 1
        figure_rotate_length_8_4 dw 2

        ; Девятая фигура
        figure_9_1 db "0", "1", "1", "2", "1", "1"
        length_mass_figure_9_1 dw 6
        figure_bottom_9_1 db 2, 0, 2, 1, 1, 2
        figure_bottom_length_9_1 dw 3
        figure_left_sides_9_1 db 0, 0, 1, -1
        figure_left_sides_length_9_1 dw 2
        figure_right_sides_9_1 db 0, 3, 1, 2
        figure_right_sides_length_9_1 dw 2
        figure_rotate_9_1 db 0, 0, 2, 1
        figure_rotate_length_9_1 dw 2

        figure_9_2 db "1", "0", "2", "1", "1", "2", "0", "1"
        length_mass_figure_9_2 dw 8
        figure_bottom_9_2 db 2, 0, 3, 1
        figure_bottom_length_9_2 dw 2
        figure_left_sides_9_2 db 0, -1, 1, -1, 2, 0
        figure_left_sides_length_9_2 dw 3
        figure_right_sides_9_2 db 0, 1, 1, 2, 2, 2
        figure_right_sides_length_9_2 dw 3
        figure_rotate_9_2 db 0, 1, 0, 2
        figure_rotate_length_9_2 dw 2

        ; Десятая фигура
        figure_10_1 db "1", "1", "0", "2", "0", "1", "1"
        length_mass_figure_10_1 dw 7
        figure_bottom_10_1 db 1, 0, 2, 1, 2, 2
        figure_bottom_length_10_1 dw 3
        figure_left_sides_10_1 db 0, -1, 1, 0
        figure_left_sides_length_10_1 dw 2
        figure_right_sides_10_1 db 0, 2, 1, 3
        figure_right_sides_length_10_1 dw 2
        figure_rotate_10_1 db 1, 0, 2, 0
        figure_rotate_length_10_1 dw 2

        figure_10_2 db "0", "1", "2", "1", "1", "2", "1", "0"
        length_mass_figure_10_2 dw 8
        figure_bottom_10_2 db 3, 0, 2, 1
        figure_bottom_length_10_2 dw 2
        figure_left_sides_10_2 db 0, 0, 1, -1, 2, -1
        figure_left_sides_length_10_2 dw 3
        figure_right_sides_10_2 db 0, 2, 1, 2, 2, 1
        figure_right_sides_length_10_2 dw 3
        figure_rotate_10_2 db 0, 0, 1, 2
        figure_rotate_length_10_2 dw 2

        ; Одиннадцатая фигура
        figure_11_1 db "0", "1", "2", "0", "1", "2", "0", "1", "2", "1", "0", "1"
        length_mass_figure_11_1 dw 12
        figure_bottom_11_1 db 4, 0, 3, 1, 4, 2
        figure_bottom_length_11_1 dw 3
        figure_left_sides_11_1 db 0, 0, 1, 0, 2, 0, 3, -1
        figure_left_sides_length_11_1 dw 4
        figure_right_sides_11_1 db 0, 2, 1, 2, 2, 2, 3, 3
        figure_right_sides_length_11_1 dw 4
        figure_rotate_11_1 db 0, 0, 1, 2, 1, 3, 2, 0
        figure_rotate_length_11_1 dw 4

        figure_11_2 db "1", "0", "0", "0", "2", "0", "1", "1", "1", "2", "1"
        length_mass_figure_11_2 dw 11
        figure_bottom_11_2 db 1, 0, 3, 0, 2, 1, 2, 2, 2, 3
        figure_bottom_length_11_2 dw 5
        figure_left_sides_11_2 db 0, -1, 1, 0, 2, -1
        figure_left_sides_length_11_2 dw 3
        figure_right_sides_11_2 db 0, 1, 1, 4, 2, 1
        figure_right_sides_length_11_2 dw 3
        figure_rotate_11_2 db 0, 2, 2, 1, 3, 1
        figure_rotate_length_11_2 dw 3

        figure_11_3 db "1", "0", "1", "2", "0", "1", "0", "2", "0", "1", "0", "2", "0", "1"
        length_mass_figure_11_3 dw 14
        figure_bottom_11_3 db 1, 0, 1, 2, 4, 1
        figure_bottom_length_11_3 dw 3
        figure_left_sides_11_3 db 0, -1, 1, 0, 2, 0, 3, 0
        figure_left_sides_length_11_3 dw 4
        figure_right_sides_11_3 db 0, 3, 1, 2, 2, 2, 3, 2
        figure_right_sides_length_11_3 dw 4
        figure_rotate_11_3 db 0, 3, 1, 0, 1, 2, 2, 2, 3, 2
        figure_rotate_length_11_3 dw 5

        figure_11_4 db "0", "0", "0", "1", "2", "1", "1", "1", "0", "2", "0", "0", "0", "1"
        length_mass_figure_11_4 dw 14
        figure_bottom_11_4 db 1, 3, 2, 0, 2, 1, 2, 2, 3, 3
        figure_bottom_length_11_4 dw 5
        figure_left_sides_11_4 db 0, 2, 1, -1, 2, 2
        figure_left_sides_length_11_4 dw 3
        figure_right_sides_11_4 db 0, 4, 1, 3, 2, 4
        figure_right_sides_length_11_4 dw 3
        figure_rotate_11_4 db 0, 1, 2, 1, 3, 0, 3, 2
        figure_rotate_length_11_4 dw 4

    old_handler_keyboard09h dd ?
    current_symbol_key db 0
    up_click db 0
    down_click db 0
    left_click db 0
    right_click db 0
    stop_move_flag db 0
    end_move_flag db 0
    rotate_figure_flag db 0
    drop_figure_flag db 0
    speed_inc_flag db 0
    speed_dec_flag db 0
    stop_game_flag db 0
    pause_game_flag db 0
    new_game_flag db 0
    exit_flag db 0

    old_handler_timer08h dd ?
    timer_tick db 0
    default_speed db 18
    speed db 18
    move_down_flag db 0

.code
    org 100h

    entry:
        main:
            call set_video_mode

            call draw_game_area
            call clean_game_area ; чтобы в стакане был только чёрный цвет

            call write_help_text

            call write_next_text

            call write_score_text

            call write_speed_text

            ; Стартовая фигура
            call get_random_color_and_figure
            call draw_figures_statistic ; получили первую статистику по фигурам
            call prediction_figure
            call get_new_figure_number

            call set_handler_keyboard09h

            call set_handler_timer08h

            @game_loop:
                cmp pause_game_flag, 1
                je @pause_game

                cmp new_game_flag, 1
                je @new_game

                cmp exit_flag, 1
                je exit

                cmp move_down_flag, 1
                je @auto_move_down

                cmp rotate_figure_flag, 1
                je @rotate_figure

                cmp drop_figure_flag, 1
                je @do_drop_figure

                cmp speed_inc_flag, 1
                je @inc_speed

                cmp speed_dec_flag, 1
                je @dec_speed

                cmp up_click, 1
                je @move_up
                cmp down_click, 1
                je @move_down
                cmp left_click, 1
                je @move_left
                cmp right_click, 1
                je @move_right
                jmp @game_loop

                @move_up:
                    mov up_click, 0

                    ; Только в режиме стопа
                    cmp stop_game_flag, 0
                    je @game_loop

                    ; Проверим верх стакана
                    mov ax, top_pos_glass
                    cmp current_row, ax
                    je @game_loop

                    call clean_current_figure
                    dec current_row ; пошли выше
                    call draw_figure_number
                    jmp @game_loop

                @move_down:
                    mov down_click, 0

                    call check_bottom_figure
                    cmp end_move_flag, 1 ; остановить ли фигуру ? Если да, то нужна новая
                    je @check_end_game

                    call clean_current_figure
                    inc current_row ; пошли ниже
                    call draw_figure_number
                    jmp @game_loop

                @move_left:
                    mov left_click, 0

                    call check_left_sides_figure
                    cmp stop_move_flag, 1 ; прочекали, что двигать нельзя
                    je @dont_move ; не сдвинули

                    call clean_current_figure
                    sub current_col, 2
                    call draw_figure_number
                    jmp @game_loop

                @move_right:
                    mov right_click, 0

                    call check_right_sides_figure
                    cmp stop_move_flag, 1 ; прочекали, что двигать нельзя
                    je @dont_move ; не сдвинули

                    call clean_current_figure
                    add current_col, 2
                    call draw_figure_number
                    jmp @game_loop

                @auto_move_down:
                    mov move_down_flag, 0 ; сбросили флаг

                    cmp stop_game_flag, 1 ; режим стопа (фигура не падает)
                    je @check_state_game

                    call check_bottom_figure
                    cmp end_move_flag, 1 ; остановить ли фигуру ? Если да, то нужна новая
                    je @check_end_game

                    call clean_current_figure
                    inc current_row ; пошли ниже
                    call draw_figure_number ; рисуем
                    jmp @game_loop

                @appear_new_figure:
                    mov end_move_flag, 0 ; сбросили флаг
                    mov move_down_flag, 1 ; запустим сразу фигуру

                    ; Чтоб повеселее
                    mov di, 350 ; разное число - разный звук
                    mov bx, 50 ; длительность
                    call make_sound

                    ; Ну у нас до этого фигура встала, надо бы проверить полные строки и обновить счёт
                    call check_full_row
                    call write_score_text
                    call draw_figures_statistic

                    ; Взяли фигуру из предикшина
                    mov al, predicted_color
                    mov color, al
                    mov al, predicted_figure_num
                    mov current_figure, al

                    mov al, predicted_rotate_pos_figure
                    mov rotate_pos_figure, al
                    call get_new_figure_number

                    ; Сделали предикшин
                    call prediction_figure
                    jmp @game_loop

                @dont_move:
                    mov stop_move_flag, 0 ; сбросили флаг

                    jmp @game_loop

                @rotate_figure:
                    mov rotate_figure_flag, 0 ; сбросили флаг

                    ; Можем повернуть ?
                    call check_rotate_figure
                    cmp stop_rotate_flag, 1 ; прочекали, что вертеть нельзя
                    je @dont_rotate ; не сдвинули

                    cmp rotate_pos_figure, 4 ; если конечное положение
                    je @reset_rotate

                    ; Вертим
                    call clean_current_figure ; очистили предыдущую фигуру
                    inc rotate_pos_figure ; вертим
                    call draw_figure_number ; тут же нарисовали
                    jmp @game_loop

                    @reset_rotate:
                        call clean_current_figure ; очистили предыдущую фигуру
                        mov rotate_pos_figure, 1 ; сбросили положение
                        call draw_figure_number ; тут же нарисовали
                        jmp @game_loop

                    @dont_rotate:
                        mov stop_rotate_flag, 0 ; сбросили флаг после всех проверок

                        jmp @game_loop

                @do_drop_figure:
                    call check_bottom_figure
                    cmp end_move_flag, 1
                    je @set_drop_figure_flag_off

                    call clean_current_figure
                    inc current_row ; пошли ниже
                    call draw_figure_number
                    jmp @do_drop_figure

                    @set_drop_figure_flag_off:
                        mov drop_figure_flag, 0 ; сбросили флаг
                        mov move_down_flag, 1 ; для мгновенной фиксации
                        inc current_row ; дропаем окончательно
                        jmp @game_loop

                @inc_speed:
                    mov speed_inc_flag, 0 ; сбросили флаг

                    cmp speed, 0
                    je @skip_inc_speed
                    dec speed
                    mov al, speed
                    mov timer_tick, al ; установим сразу таймер в значение скорости
                    call write_speed_text ; отрисуем новую скорость
                    @skip_inc_speed:
                        jmp @game_loop

                @dec_speed:
                    mov speed_dec_flag, 0 ; сбросили флаг

                    cmp speed, 18
                    je @skip_dec_speed
                    inc speed
                    mov al, speed
                    mov timer_tick, al ; установим сразу таймер в значение скорости
                    call write_speed_text ; отрисуем новую скорость
                    @skip_dec_speed:
                        jmp @game_loop

                @check_state_game:
                    cmp end_move_flag, 1 ; если фигуру дропнули и в стопе
                    je @appear_new_figure ; то нужна новая
                    jmp @game_loop

                @new_game:
                    mov new_game_flag, 0
                    mov pause_game_flag, 0
                    mov timer_tick, 0 ; сбросим таймер

                    call drop_flags
                    call write_end_game_text_clean ; Вдруг был текст проигрыша
                    call clean_game_area
                    call clean_statistics
                    jmp @appear_new_figure

                @pause_game:
                    cmp new_game_flag, 1
                    je @new_game
                    cmp exit_flag, 1
                    je exit
                    jmp @game_loop

                @check_end_game:
                    mov ax, top_pos_glass
                    cmp current_row, ax
                    je @end_game
                    jne @appear_new_figure

                @end_game:
                    call write_end_game_text
                    mov pause_game_flag, 1
                    jmp @pause_game

        ; Устанавливаем 3-й видео режим
        set_video_mode proc
            mov ah, 00h
            mov al, 03h
            int 10h

            ret
        set_video_mode endp

        ; Рисует symbol цвета color в col и row
        draw proc
            ; Пишем в видеопамять
            mov ax, video_memory
            mov es, ax

            ; Вычисляем позицию (работаем с dw)
            mov ax, row_size
            mul row
            add ax, col
            mul symb_size ; символ занимает 2 байта

            ; Устанавливаем куда рисовать
            mov di, ax
            mov ah, color ; цвет
            mov al, symbol; символ
            mov es:[di], ax

            ret
        draw endp

        ; Рисуем игровое поле
        draw_game_area proc
            mov al, color_glass
            mov color, al
            mov symbol, 20h ; пробельчик

            ; Левая стенка
            mov bx, top_pos_glass
            mov cx, depth_glass
            ; Кладём начальную позицию стенки
            mov ax, start_pos_glass
            mov col, ax
            mov row, bx
            l_left:
                call draw
                inc col
                call draw
                dec col
                inc row
                loop l_left

            ; Дно. Умножим ширину экрана на размер символа
            mov ax, width_glass
            mul symb_size ; т.к. ширина в клетках фигуры
            mov cx, ax
            mov ax, down_pos_glass
            mov row, ax
            l_down:
                call draw
                inc col
                loop l_down

            ; Правая стенка
            mov bx, top_pos_glass
            mov cx, depth_glass
            ; Расчитаем позицию правой стенки относительно ширины стакана
            mov ax, width_glass
            mul symb_size
            add ax, start_pos_glass
            mov col, ax
            dec col ; да простит меня Господь
            mov row, bx
            l_right:
                call draw
                dec col
                call draw
                inc col
                inc row
                loop l_right

            ret
        draw_game_area endp

        clean_game_area proc
            mov color, 00h
            mov symbol, 20h ; пробельчик

            ; Левая стенка
            mov bx, top_pos_glass
            mov cx, depth_glass
            ; Кладём начальную позицию стенки
            mov ax, start_pos_glass
            mov col, ax
            ; Сдвигаемся на первую ячейку стакана
            add col, 2
            clean_rows:
                mov row, bx
                push cx
                push col
                mov ax, width_glass
                mul symb_size ; т.к. ширина в клетках фигуры
                mov cx, ax
                sub cx, 4 ; т.к. стенки стоят на дне
                clean_row:
                    call draw
                    inc col
                    loop clean_row
                pop col
                pop cx
                inc bx
                loop clean_rows

            ret
        clean_game_area endp

        ; Без комментариев + подсчёт всех фигур
        get_random_color_and_figure proc
            mov ah, 2ch
            int 21h

            ; Берём сумму секунд и миллисекунд
            add dl, dh
            xor dh, dh

            mov ax, dx
            div colors_len ; возьмём по модулю
            mov random_num, ah ; остаток взяли

            mov si, offset colors
            call get_random_elem
            mov color, bl

            mov ax, dx
            div figures_len ; возьмём по модулю
            mov random_num, ah ; остаток взяли

            mov si, offset figures
            call get_random_elem
            mov current_figure, bl

            ; Подсчитаем
            @extreme_check:
            cmp current_figure, 1
            je @inc_figure_1_time

            cmp current_figure, 2
            je @inc_figure_2_time

            cmp current_figure, 3
            je @inc_figure_3_time

            cmp current_figure, 4
            je @inc_figure_4_time

            cmp current_figure, 5
            je @inc_figure_5_time

            cmp current_figure, 6
            je @inc_figure_6_time

            cmp current_figure, 7
            je @inc_figure_7_time

            cmp current_figure, 8
            je @inc_figure_8_time

            cmp current_figure, 9
            je @inc_figure_9_time

            cmp current_figure, 10
            je @inc_figure_10_time

            cmp current_figure, 11
            je @inc_figure_11_time

            @inc_figure_1_time:
                inc figure_1_time
                jmp @continue_procedure

            @inc_figure_2_time:
                inc figure_2_time
                jmp @continue_procedure

            @inc_figure_3_time:
                inc figure_3_time
                jmp @continue_procedure

            @inc_figure_4_time:
                inc figure_4_time
                jmp @continue_procedure

            @inc_figure_5_time:
                inc figure_5_time
                jmp @continue_procedure

            @inc_figure_6_time:
                inc figure_6_time
                jmp @continue_procedure

            @inc_figure_7_time:
                inc figure_7_time
                jmp @continue_procedure

            @inc_figure_8_time:
                inc figure_8_time
                jmp @continue_procedure

            @inc_figure_9_time:
                inc figure_9_time
                jmp @continue_procedure

            @inc_figure_10_time:
                inc figure_10_time
                jmp @continue_procedure

            @inc_figure_11_time:
                inc figure_11_time
                jmp @continue_procedure

            @continue_procedure:
            cmp extreme_check_flag, 1
            je @end_extreme_check

            mov ax, dx
            div poses_len ; возьмём по модулю
            mov random_num, ah ; остаток взяли

            mov si, offset figure_poses
            call get_random_elem
            mov rotate_pos_figure, bl

            ret

            ; Вспомогательная дичь
            get_random_elem proc
                xor ch, ch ; на всякий случай
                mov cl, random_num
                l_random_elem:
                    inc si
                    loop l_random_elem
                mov bl, [si]

                ret
            get_random_elem endp
        get_random_color_and_figure endp

        ; Отрисовывает фигуру по current_row, current_col
        draw_figure proc
            call set_current_position

            mov symbol, 20h
            mov bp, 0
            l:
                mov dl, [si] ; получаем из массива символ
                cmp dl, "0"
                je @empty
                cmp dl, "1"
                je @continue_draw_figure
                cmp dl, "2"
                je @new_line
                @continue_draw_figure:
                call draw
                inc col
                inc bp
                call draw
                inc col ; сдвигаемся по экрану
                inc bp
                @skip:
                inc si ; сдвигаемся по массиву
                loop l

            ret

            @empty:
                add bp, 2
                add col, 2
                jmp @skip
            @new_line:
                inc row
                mov bx, col
                sub bx, bp
                mov col, bx
                mov bp, 0
                jmp @skip

            ; Устанавливаем позицию отрисовки из текущей позиции
            set_current_position proc
                mov ax, current_row
                mov bx, current_col
                mov row, ax
                mov col, bx

                ret
            set_current_position endp
        draw_figure endp

        ; Рисует фигуру по current_figure (si)
        draw_figure_number proc
            cmp current_figure, 1
            je @figure_1
            cmp current_figure, 2
            je @figure_2
            cmp current_figure, 3
            je @figure_3
            cmp current_figure, 4
            je @figure_4
            cmp current_figure, 5
            je @figure_5
            cmp current_figure, 6
            je @figure_6
            cmp current_figure, 7
            je @figure_7
            cmp current_figure, 8
            je @figure_8
            cmp current_figure, 9
            je @figure_9
            cmp current_figure, 10
            je @figure_10
            cmp current_figure, 11
            je @figure_11

            @figure_1:
                mov si, offset figure_1
                mov cx, length_mass_figure_1

                jmp @continue_draw_figure_number

            @figure_2:
                cmp rotate_pos_figure, 1
                je @figure_2_1
                cmp rotate_pos_figure, 2
                je @figure_2_2
                cmp rotate_pos_figure, 3
                je @figure_2_1
                cmp rotate_pos_figure, 4
                je @figure_2_2

                @figure_2_1:
                    mov si, offset figure_2_1
                    mov cx, length_mass_figure_2_1
                    jmp @continue_draw_figure_number

                @figure_2_2:
                    mov si, offset figure_2_2
                    mov cx, length_mass_figure_2_2
                    jmp @continue_draw_figure_number

            @figure_3:
                cmp rotate_pos_figure, 1
                je @figure_3_1
                cmp rotate_pos_figure, 2
                je @figure_3_2
                cmp rotate_pos_figure, 3
                je @figure_3_1
                cmp rotate_pos_figure, 4
                je @figure_3_2

                @figure_3_1:
                    mov si, offset figure_3_1
                    mov cx, length_mass_figure_3_1
                    jmp @continue_draw_figure_number

                @figure_3_2:
                    mov si, offset figure_3_2
                    mov cx, length_mass_figure_3_2
                    jmp @continue_draw_figure_number

            @figure_4:
                cmp rotate_pos_figure, 1
                je @figure_4_1
                cmp rotate_pos_figure, 2
                je @figure_4_2
                cmp rotate_pos_figure, 3
                je @figure_4_3
                cmp rotate_pos_figure, 4
                je @figure_4_4

                @figure_4_1:
                    mov si, offset figure_4_1
                    mov cx, length_mass_figure_4_1
                    jmp @continue_draw_figure_number

                @figure_4_2:
                    mov si, offset figure_4_2
                    mov cx, length_mass_figure_4_2
                    jmp @continue_draw_figure_number

                @figure_4_3:
                    mov si, offset figure_4_3
                    mov cx, length_mass_figure_4_3
                    jmp @continue_draw_figure_number

                @figure_4_4:
                    mov si, offset figure_4_4
                    mov cx, length_mass_figure_4_4
                    jmp @continue_draw_figure_number

            @figure_5:
                cmp rotate_pos_figure, 1
                je @figure_5_1
                cmp rotate_pos_figure, 2
                je @figure_5_2
                cmp rotate_pos_figure, 3
                je @figure_5_3
                cmp rotate_pos_figure, 4
                je @figure_5_4

                @figure_5_1:
                    mov si, offset figure_5_1
                    mov cx, length_mass_figure_5_1
                    jmp @continue_draw_figure_number

                @figure_5_2:
                    mov si, offset figure_5_2
                    mov cx, length_mass_figure_5_2
                    jmp @continue_draw_figure_number

                @figure_5_3:
                    mov si, offset figure_5_3
                    mov cx, length_mass_figure_5_3
                    jmp @continue_draw_figure_number

                @figure_5_4:
                    mov si, offset figure_5_4
                    mov cx, length_mass_figure_5_4
                    jmp @continue_draw_figure_number

            @figure_6:
                mov si, offset figure_6
                mov cx, length_mass_figure_6
                jmp @continue_draw_figure_number

            @figure_7:
                cmp rotate_pos_figure, 1
                je @figure_7_1
                cmp rotate_pos_figure, 2
                je @figure_7_2
                cmp rotate_pos_figure, 3
                je @figure_7_3
                cmp rotate_pos_figure, 4
                je @figure_7_4

                @figure_7_1:
                    mov si, offset figure_7_1
                    mov cx, length_mass_figure_7_1
                    jmp @continue_draw_figure_number

                @figure_7_2:
                    mov si, offset figure_7_2
                    mov cx, length_mass_figure_7_2
                    jmp @continue_draw_figure_number

                @figure_7_3:
                    mov si, offset figure_7_3
                    mov cx, length_mass_figure_7_3
                    jmp @continue_draw_figure_number

                @figure_7_4:
                    mov si, offset figure_7_4
                    mov cx, length_mass_figure_7_4
                    jmp @continue_draw_figure_number

            @figure_8:
                cmp rotate_pos_figure, 1
                je @figure_8_1
                cmp rotate_pos_figure, 2
                je @figure_8_2
                cmp rotate_pos_figure, 3
                je @figure_8_3
                cmp rotate_pos_figure, 4
                je @figure_8_4

                @figure_8_1:
                    mov si, offset figure_8_1
                    mov cx, length_mass_figure_8_1
                    jmp @continue_draw_figure_number

                @figure_8_2:
                    mov si, offset figure_8_2
                    mov cx, length_mass_figure_8_2
                    jmp @continue_draw_figure_number

                @figure_8_3:
                    mov si, offset figure_8_3
                    mov cx, length_mass_figure_8_3
                    jmp @continue_draw_figure_number

                @figure_8_4:
                    mov si, offset figure_8_4
                    mov cx, length_mass_figure_8_4
                    jmp @continue_draw_figure_number

            @figure_9:
                cmp rotate_pos_figure, 1
                je @figure_9_1
                cmp rotate_pos_figure, 2
                je @figure_9_2
                cmp rotate_pos_figure, 3
                je @figure_9_1
                cmp rotate_pos_figure, 4
                je @figure_9_2

                @figure_9_1:
                    mov si, offset figure_9_1
                    mov cx, length_mass_figure_9_1
                    jmp @continue_draw_figure_number

                @figure_9_2:
                    mov si, offset figure_9_2
                    mov cx, length_mass_figure_9_2
                    jmp @continue_draw_figure_number

            @figure_10:
                cmp rotate_pos_figure, 1
                je @figure_10_1
                cmp rotate_pos_figure, 2
                je @figure_10_2
                cmp rotate_pos_figure, 3
                je @figure_10_1
                cmp rotate_pos_figure, 4
                je @figure_10_2

                @figure_10_1:
                    mov si, offset figure_10_1
                    mov cx, length_mass_figure_10_1
                    jmp @continue_draw_figure_number

                @figure_10_2:
                    mov si, offset figure_10_2
                    mov cx, length_mass_figure_10_2
                    jmp @continue_draw_figure_number

            @figure_11:
                cmp rotate_pos_figure, 1
                je @figure_11_1
                cmp rotate_pos_figure, 2
                je @figure_11_2
                cmp rotate_pos_figure, 3
                je @figure_11_3
                cmp rotate_pos_figure, 4
                je @figure_11_4

                @figure_11_1:
                    mov si, offset figure_11_1
                    mov cx, length_mass_figure_11_1
                    jmp @continue_draw_figure_number

                @figure_11_2:
                    mov si, offset figure_11_2
                    mov cx, length_mass_figure_11_2
                    jmp @continue_draw_figure_number

                @figure_11_3:
                    mov si, offset figure_11_3
                    mov cx, length_mass_figure_11_3
                    jmp @continue_draw_figure_number

                @figure_11_4:
                    mov si, offset figure_11_4
                    mov cx, length_mass_figure_11_4
                    jmp @continue_draw_figure_number

            @continue_draw_figure_number:
            call draw_figure

            ret
        draw_figure_number endp

        ; Рисует фигуру в стартовой позиции
        get_new_figure_number proc
            call set_start_position
            call draw_figure_number

            ret

            ; Устанаваливает current_row, current_col в стартовые положения
            set_start_position proc
                mov ax, start_pos_row
                mov bx, start_pos_col
                mov current_row, ax
                mov current_col, bx

                ret
            set_start_position endp
        get_new_figure_number endp

        ; Отрисовывает будущую фигуру
        prediction_figure proc
            push current_row
            push current_col

            ; Удалили старую, которую предсказали
            mov current_row, 3
            mov current_col, 66

            ; Сохранили текущий цвет
            mov al, color
            mov color_temp, al
            mov al, current_figure
            mov figure_num_temp, al
            mov al, rotate_pos_figure
            mov rotate_pos_figure_temp, al

            ; Удалили предыдущий предикшин
            call clean_current_figure

            ; Сделали предикшин и отрисовали в месте предсказания
            call get_random_color_and_figure
            call draw_figure_number

            ; Засейвили все атрибуты фигуры из предикшина
            mov al, color
            mov predicted_color, al
            mov al, current_figure
            mov predicted_figure_num, al
            mov al, rotate_pos_figure
            mov predicted_rotate_pos_figure, al

            ; Вернули всё как было
            mov al, color_temp
            mov color, al
            mov al, figure_num_temp
            mov current_figure, al
            mov al, rotate_pos_figure_temp
            mov rotate_pos_figure, al

            pop current_col
            pop current_row

            ret
        prediction_figure endp

        ; Без комментариев
        clean_current_figure proc
            mov al, color ; сохранили цвет
            push ax ; где-то в процедуре ax перетрётся
            mov color, 00h ; поставим чёрный, чтобы стереть фигуру с прошлой позиции
            call draw_figure_number
            pop ax
            mov color, al ; вернули цвет

            ret
        clean_current_figure endp

        ; Пиздец... у всех праздники, а у меня ASM
        ; Блок - 2 символа, мы всегда проверяем 1 краешек, ввиду особенности игрового поля
        ; Проверяет днище current_figure и прочим массивам связанных с ней
        check_bottom_figure proc
            ; Дальше надо выяснить тип фигуры и узнать их днища
            cmp current_figure, 1
            je @check_bottom_figure_1
            cmp current_figure, 2
            je @check_bottom_figure_2
            cmp current_figure, 3
            je @check_bottom_figure_3
            cmp current_figure, 4
            je @check_bottom_figure_4
            cmp current_figure, 5
            je @check_bottom_figure_5
            cmp current_figure, 6
            je @check_bottom_figure_6
            cmp current_figure, 7
            je @check_bottom_figure_7
            cmp current_figure, 8
            je @check_bottom_figure_8
            cmp current_figure, 9
            je @check_bottom_figure_9
            cmp current_figure, 10
            je @check_bottom_figure_10
            cmp current_figure, 11
            je @check_bottom_figure_11

            @check_bottom_figure_1:
                ; Вычисляем позицию
                mov cx, figure_bottom_length_1
                mov di, offset figure_bottom_1
                jmp @continue_bottom_figure_check

            @check_bottom_figure_2:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_bottom_2_1
                cmp rotate_pos_figure, 2
                je @figure_bottom_2_2
                cmp rotate_pos_figure, 3
                je @figure_bottom_2_1
                cmp rotate_pos_figure, 4
                je @figure_bottom_2_2

                @figure_bottom_2_1:
                    mov cx, figure_bottom_length_2_1
                    mov di, offset figure_bottom_2_1
                    jmp @continue_bottom_figure_check

                @figure_bottom_2_2:
                    mov cx, figure_bottom_length_2_2
                    mov di, offset figure_bottom_2_2
                    jmp @continue_bottom_figure_check

            @check_bottom_figure_3:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_bottom_3_1
                cmp rotate_pos_figure, 2
                je @figure_bottom_3_2
                cmp rotate_pos_figure, 3
                je @figure_bottom_3_1
                cmp rotate_pos_figure, 4
                je @figure_bottom_3_2

                @figure_bottom_3_1:
                    mov cx, figure_bottom_length_3_1
                    mov di, offset figure_bottom_3_1
                    jmp @continue_bottom_figure_check

                @figure_bottom_3_2:
                    mov cx, figure_bottom_length_3_2
                    mov di, offset figure_bottom_3_2
                    jmp @continue_bottom_figure_check

            @check_bottom_figure_4:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_bottom_4_1
                cmp rotate_pos_figure, 2
                je @figure_bottom_4_2
                cmp rotate_pos_figure, 3
                je @figure_bottom_4_3
                cmp rotate_pos_figure, 4
                je @figure_bottom_4_4

                @figure_bottom_4_1:
                    mov cx, figure_bottom_length_4_1
                    mov di, offset figure_bottom_4_1
                    jmp @continue_bottom_figure_check

                @figure_bottom_4_2:
                    mov cx, figure_bottom_length_4_2
                    mov di, offset figure_bottom_4_2
                    jmp @continue_bottom_figure_check

                @figure_bottom_4_3:
                    mov cx, figure_bottom_length_4_3
                    mov di, offset figure_bottom_4_3
                    jmp @continue_bottom_figure_check

                @figure_bottom_4_4:
                    mov cx, figure_bottom_length_4_4
                    mov di, offset figure_bottom_4_4
                    jmp @continue_bottom_figure_check

            @check_bottom_figure_5:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_bottom_5_1
                cmp rotate_pos_figure, 2
                je @figure_bottom_5_2
                cmp rotate_pos_figure, 3
                je @figure_bottom_5_3
                cmp rotate_pos_figure, 4
                je @figure_bottom_5_4

                @figure_bottom_5_1:
                    mov cx, figure_bottom_length_5_1
                    mov di, offset figure_bottom_5_1
                    jmp @continue_bottom_figure_check

                @figure_bottom_5_2:
                    mov cx, figure_bottom_length_5_2
                    mov di, offset figure_bottom_5_2
                    jmp @continue_bottom_figure_check

                @figure_bottom_5_3:
                    mov cx, figure_bottom_length_5_3
                    mov di, offset figure_bottom_5_3
                    jmp @continue_bottom_figure_check

                @figure_bottom_5_4:
                    mov cx, figure_bottom_length_5_4
                    mov di, offset figure_bottom_5_4
                    jmp @continue_bottom_figure_check

            @check_bottom_figure_6:
                ; Вычисляем позицию
                mov cx, figure_bottom_length_6
                mov di, offset figure_bottom_6
                jmp @continue_bottom_figure_check

            @check_bottom_figure_7:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_bottom_7_1
                cmp rotate_pos_figure, 2
                je @figure_bottom_7_2
                cmp rotate_pos_figure, 3
                je @figure_bottom_7_3
                cmp rotate_pos_figure, 4
                je @figure_bottom_7_4

                @figure_bottom_7_1:
                    mov cx, figure_bottom_length_7_1
                    mov di, offset figure_bottom_7_1
                    jmp @continue_bottom_figure_check

                @figure_bottom_7_2:
                    mov cx, figure_bottom_length_7_2
                    mov di, offset figure_bottom_7_2
                    jmp @continue_bottom_figure_check

                @figure_bottom_7_3:
                    mov cx, figure_bottom_length_7_3
                    mov di, offset figure_bottom_7_3
                    jmp @continue_bottom_figure_check

                @figure_bottom_7_4:
                    mov cx, figure_bottom_length_7_4
                    mov di, offset figure_bottom_7_4
                    jmp @continue_bottom_figure_check

            @check_bottom_figure_8:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_bottom_8_1
                cmp rotate_pos_figure, 2
                je @figure_bottom_8_2
                cmp rotate_pos_figure, 3
                je @figure_bottom_8_3
                cmp rotate_pos_figure, 4
                je @figure_bottom_8_4

                @figure_bottom_8_1:
                    mov cx, figure_bottom_length_8_1
                    mov di, offset figure_bottom_8_1
                    jmp @continue_bottom_figure_check

                @figure_bottom_8_2:
                    mov cx, figure_bottom_length_8_2
                    mov di, offset figure_bottom_8_2
                    jmp @continue_bottom_figure_check

                @figure_bottom_8_3:
                    mov cx, figure_bottom_length_8_3
                    mov di, offset figure_bottom_8_3
                    jmp @continue_bottom_figure_check

                @figure_bottom_8_4:
                    mov cx, figure_bottom_length_8_4
                    mov di, offset figure_bottom_8_4
                    jmp @continue_bottom_figure_check

            @check_bottom_figure_9:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_bottom_9_1
                cmp rotate_pos_figure, 2
                je @figure_bottom_9_2
                cmp rotate_pos_figure, 3
                je @figure_bottom_9_1
                cmp rotate_pos_figure, 4
                je @figure_bottom_9_2

                @figure_bottom_9_1:
                    mov cx, figure_bottom_length_9_1
                    mov di, offset figure_bottom_9_1
                    jmp @continue_bottom_figure_check

                @figure_bottom_9_2:
                    mov cx, figure_bottom_length_9_2
                    mov di, offset figure_bottom_9_2
                    jmp @continue_bottom_figure_check

            @check_bottom_figure_10:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_bottom_10_1
                cmp rotate_pos_figure, 2
                je @figure_bottom_10_2
                cmp rotate_pos_figure, 3
                je @figure_bottom_10_1
                cmp rotate_pos_figure, 4
                je @figure_bottom_10_2

                @figure_bottom_10_1:
                    mov cx, figure_bottom_length_10_1
                    mov di, offset figure_bottom_10_1
                    jmp @continue_bottom_figure_check

                @figure_bottom_10_2:
                    mov cx, figure_bottom_length_10_2
                    mov di, offset figure_bottom_10_2
                    jmp @continue_bottom_figure_check

            @check_bottom_figure_11:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_bottom_11_1
                cmp rotate_pos_figure, 2
                je @figure_bottom_11_2
                cmp rotate_pos_figure, 3
                je @figure_bottom_11_3
                cmp rotate_pos_figure, 4
                je @figure_bottom_11_4

                @figure_bottom_11_1:
                    mov cx, figure_bottom_length_11_1
                    mov di, offset figure_bottom_11_1
                    jmp @continue_bottom_figure_check

                @figure_bottom_11_2:
                    mov cx, figure_bottom_length_11_2
                    mov di, offset figure_bottom_11_2
                    jmp @continue_bottom_figure_check

                @figure_bottom_11_3:
                    mov cx, figure_bottom_length_11_3
                    mov di, offset figure_bottom_11_3
                    jmp @continue_bottom_figure_check

                @figure_bottom_11_4:
                    mov cx, figure_bottom_length_11_4
                    mov di, offset figure_bottom_11_4
                    jmp @continue_bottom_figure_check

            @continue_bottom_figure_check:
            call help_check_bottom_figure

            ret

            ; Вспомогательная для проверки и установки флага днища
            help_check_crash_and_set_end_move_flag proc
                ; Устанавливаем откуда читать
                mov si, ax
                mov ax, es:[si]

                ; Если дно
                cmp ah, color_glass
                je @set_end_move_flag

                ; Если фигура
                mov si, offset colors
                xor ch, ch ; так надо
                mov cl, colors_len
                check_colors_loop_bottom:
                    cmp ah, [si]
                    je @set_end_move_flag
                    inc si
                    loop check_colors_loop_bottom

                jmp @end_check_bottom

                @set_end_move_flag:
                    mov end_move_flag, 1

                @end_check_bottom:

                ret
            help_check_crash_and_set_end_move_flag endp

            ; Вспомогательная дичь
            help_check_bottom_figure proc
                l_check_bottom_figure:
                    push cx
                    call help_check_cells
                    call help_check_crash_and_set_end_move_flag
                    pop cx
                    cmp end_move_flag, 1
                    je @end_help_check_bottom
                    loop l_check_bottom_figure

                @end_help_check_bottom:

                ret
            help_check_bottom_figure endp
        check_bottom_figure endp

        ; Получает позицию для чека из current_row и current_col (в ax) и сдвигается по массиву
        help_check_cells proc
            ; Берём из видеопамяти
            mov ax, video_memory
            mov es, ax

            mov ax, row_size
            mov bx, current_row ; т.к. нам не стоит херить current_row
            add bl, [di]
            mul bx ; здесь получили строку дна
            add ax, current_col
            inc di
            add al, [di]
            add al, [di] ; а тут положение в строке
            mul symb_size ; символ занимает 2 байта (теперь в ax позиция дна)
            inc di

            ret
        help_check_cells endp

        ; Копипаста одной из функций
        ; Проверяет левую сторону current_figure и прочим массивам связанных с ней
        check_left_sides_figure proc
            ; Дальше надо выяснить тип фигуры и узнать их стороны
            cmp current_figure, 1
            je @check_left_sides_figure_1
            cmp current_figure, 2
            je @check_left_sides_figure_2
            cmp current_figure, 3
            je @check_left_sides_figure_3
            cmp current_figure, 4
            je @check_left_sides_figure_4
            cmp current_figure, 5
            je @check_left_sides_figure_5
            cmp current_figure, 6
            je @check_left_sides_figure_6
            cmp current_figure, 7
            je @check_left_sides_figure_7
            cmp current_figure, 8
            je @check_left_sides_figure_8
            cmp current_figure, 9
            je @check_left_sides_figure_9
            cmp current_figure, 10
            je @check_left_sides_figure_10
            cmp current_figure, 11
            je @check_left_sides_figure_11

            @check_left_sides_figure_1:
                ; Вычисляем позицию
                mov cx, figure_left_sides_length_1
                mov di, offset figure_left_sides_1
                jmp @continue_left_sides_figure_check

            @check_left_sides_figure_2:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_left_sides_2_1
                cmp rotate_pos_figure, 2
                je @figure_left_sides_2_2
                cmp rotate_pos_figure, 3
                je @figure_left_sides_2_1
                cmp rotate_pos_figure, 4
                je @figure_left_sides_2_2

                @figure_left_sides_2_1:
                    mov cx, figure_left_sides_length_2_1
                    mov di, offset figure_left_sides_2_1
                    jmp @continue_left_sides_figure_check

                @figure_left_sides_2_2:
                    mov cx, figure_left_sides_length_2_2
                    mov di, offset figure_left_sides_2_2
                    jmp @continue_left_sides_figure_check

            @check_left_sides_figure_3:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_left_sides_3_1
                cmp rotate_pos_figure, 2
                je @figure_left_sides_3_2
                cmp rotate_pos_figure, 3
                je @figure_left_sides_3_1
                cmp rotate_pos_figure, 4
                je @figure_left_sides_3_2

                @figure_left_sides_3_1:
                    mov cx, figure_left_sides_length_3_1
                    mov di, offset figure_left_sides_3_1
                    jmp @continue_left_sides_figure_check

                @figure_left_sides_3_2:
                    mov cx, figure_left_sides_length_3_2
                    mov di, offset figure_left_sides_3_2
                    jmp @continue_left_sides_figure_check

            @check_left_sides_figure_4:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_left_sides_4_1
                cmp rotate_pos_figure, 2
                je @figure_left_sides_4_2
                cmp rotate_pos_figure, 3
                je @figure_left_sides_4_3
                cmp rotate_pos_figure, 4
                je @figure_left_sides_4_4

                @figure_left_sides_4_1:
                    mov cx, figure_left_sides_length_4_1
                    mov di, offset figure_left_sides_4_1
                    jmp @continue_left_sides_figure_check

                @figure_left_sides_4_2:
                    mov cx, figure_left_sides_length_4_2
                    mov di, offset figure_left_sides_4_2
                    jmp @continue_left_sides_figure_check

                @figure_left_sides_4_3:
                    mov cx, figure_left_sides_length_4_3
                    mov di, offset figure_left_sides_4_3
                    jmp @continue_left_sides_figure_check

                @figure_left_sides_4_4:
                    mov cx, figure_left_sides_length_4_4
                    mov di, offset figure_left_sides_4_4
                    jmp @continue_left_sides_figure_check

            @check_left_sides_figure_5:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_left_sides_5_1
                cmp rotate_pos_figure, 2
                je @figure_left_sides_5_2
                cmp rotate_pos_figure, 3
                je @figure_left_sides_5_3
                cmp rotate_pos_figure, 4
                je @figure_left_sides_5_4

                @figure_left_sides_5_1:
                    mov cx, figure_left_sides_length_5_1
                    mov di, offset figure_left_sides_5_1
                    jmp @continue_left_sides_figure_check

                @figure_left_sides_5_2:
                    mov cx, figure_left_sides_length_5_2
                    mov di, offset figure_left_sides_5_2
                    jmp @continue_left_sides_figure_check

                @figure_left_sides_5_3:
                    mov cx, figure_left_sides_length_5_3
                    mov di, offset figure_left_sides_5_3
                    jmp @continue_left_sides_figure_check

                @figure_left_sides_5_4:
                    mov cx, figure_left_sides_length_5_4
                    mov di, offset figure_left_sides_5_4
                    jmp @continue_left_sides_figure_check

            @check_left_sides_figure_6:
                ; Вычисляем позицию
                mov cx, figure_left_sides_length_6
                mov di, offset figure_left_sides_6
                jmp @continue_left_sides_figure_check

            @check_left_sides_figure_7:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_left_sides_7_1
                cmp rotate_pos_figure, 2
                je @figure_left_sides_7_2
                cmp rotate_pos_figure, 3
                je @figure_left_sides_7_3
                cmp rotate_pos_figure, 4
                je @figure_left_sides_7_4

                @figure_left_sides_7_1:
                    mov cx, figure_left_sides_length_7_1
                    mov di, offset figure_left_sides_7_1
                    jmp @continue_left_sides_figure_check

                @figure_left_sides_7_2:
                    mov cx, figure_left_sides_length_7_2
                    mov di, offset figure_left_sides_7_2
                    jmp @continue_left_sides_figure_check

                @figure_left_sides_7_3:
                    mov cx, figure_left_sides_length_7_3
                    mov di, offset figure_left_sides_7_3
                    jmp @continue_left_sides_figure_check

                @figure_left_sides_7_4:
                    mov cx, figure_left_sides_length_7_4
                    mov di, offset figure_left_sides_7_4
                    jmp @continue_left_sides_figure_check

            @check_left_sides_figure_8:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_left_sides_8_1
                cmp rotate_pos_figure, 2
                je @figure_left_sides_8_2
                cmp rotate_pos_figure, 3
                je @figure_left_sides_8_3
                cmp rotate_pos_figure, 4
                je @figure_left_sides_8_4

                @figure_left_sides_8_1:
                    mov cx, figure_left_sides_length_8_1
                    mov di, offset figure_left_sides_8_1
                    jmp @continue_left_sides_figure_check

                @figure_left_sides_8_2:
                    mov cx, figure_left_sides_length_8_2
                    mov di, offset figure_left_sides_8_2
                    jmp @continue_left_sides_figure_check

                @figure_left_sides_8_3:
                    mov cx, figure_left_sides_length_8_3
                    mov di, offset figure_left_sides_8_3
                    jmp @continue_left_sides_figure_check

                @figure_left_sides_8_4:
                    mov cx, figure_left_sides_length_8_4
                    mov di, offset figure_left_sides_8_4
                    jmp @continue_left_sides_figure_check

            @check_left_sides_figure_9:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_left_sides_9_1
                cmp rotate_pos_figure, 2
                je @figure_left_sides_9_2
                cmp rotate_pos_figure, 3
                je @figure_left_sides_9_1
                cmp rotate_pos_figure, 4
                je @figure_left_sides_9_2

                @figure_left_sides_9_1:
                    mov cx, figure_left_sides_length_9_1
                    mov di, offset figure_left_sides_9_1
                    jmp @continue_left_sides_figure_check

                @figure_left_sides_9_2:
                    mov cx, figure_left_sides_length_9_2
                    mov di, offset figure_left_sides_9_2
                    jmp @continue_left_sides_figure_check

            @check_left_sides_figure_10:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_left_sides_10_1
                cmp rotate_pos_figure, 2
                je @figure_left_sides_10_2
                cmp rotate_pos_figure, 3
                je @figure_left_sides_10_1
                cmp rotate_pos_figure, 4
                je @figure_left_sides_10_2

                @figure_left_sides_10_1:
                    mov cx, figure_left_sides_length_10_1
                    mov di, offset figure_left_sides_10_1
                    jmp @continue_left_sides_figure_check

                @figure_left_sides_10_2:
                    mov cx, figure_left_sides_length_10_2
                    mov di, offset figure_left_sides_10_2
                    jmp @continue_left_sides_figure_check

            @check_left_sides_figure_11:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_left_sides_11_1
                cmp rotate_pos_figure, 2
                je @figure_left_sides_11_2
                cmp rotate_pos_figure, 3
                je @figure_left_sides_11_3
                cmp rotate_pos_figure, 4
                je @figure_left_sides_11_4

                @figure_left_sides_11_1:
                    mov cx, figure_left_sides_length_11_1
                    mov di, offset figure_left_sides_11_1
                    jmp @continue_left_sides_figure_check

                @figure_left_sides_11_2:
                    mov cx, figure_left_sides_length_11_2
                    mov di, offset figure_left_sides_11_2
                    jmp @continue_left_sides_figure_check

                @figure_left_sides_11_3:
                    mov cx, figure_left_sides_length_11_3
                    mov di, offset figure_left_sides_11_3
                    jmp @continue_left_sides_figure_check

                @figure_left_sides_11_4:
                    mov cx, figure_left_sides_length_11_4
                    mov di, offset figure_left_sides_11_4
                    jmp @continue_left_sides_figure_check

            @continue_left_sides_figure_check:
            call help_check_sides_figure

            ret
        check_left_sides_figure endp

        ; Копипаста одной из функций
        ; Проверяет правую сторону current_figure и прочим массивам связанных с ней
        check_right_sides_figure proc
            ; Дальше надо выяснить тип фигуры и узнать их стороны
            cmp current_figure, 1
            je @check_right_sides_figure_1
            cmp current_figure, 2
            je @check_right_sides_figure_2
            cmp current_figure, 3
            je @check_right_sides_figure_3
            cmp current_figure, 4
            je @check_right_sides_figure_4
            cmp current_figure, 5
            je @check_right_sides_figure_5
            cmp current_figure, 6
            je @check_right_sides_figure_6
            cmp current_figure, 7
            je @check_right_sides_figure_7
            cmp current_figure, 8
            je @check_right_sides_figure_8
            cmp current_figure, 9
            je @check_right_sides_figure_9
            cmp current_figure, 10
            je @check_right_sides_figure_10
            cmp current_figure, 11
            je @check_right_sides_figure_11

            @check_right_sides_figure_1:
                ; Вычисляем позицию
                mov cx, figure_right_sides_length_1
                mov di, offset figure_right_sides_1
                jmp @continue_right_sides_figure_check

            @check_right_sides_figure_2:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_right_sides_2_1
                cmp rotate_pos_figure, 2
                je @figure_right_sides_2_2
                cmp rotate_pos_figure, 3
                je @figure_right_sides_2_1
                cmp rotate_pos_figure, 4
                je @figure_right_sides_2_2

                @figure_right_sides_2_1:
                    mov cx, figure_right_sides_length_2_1
                    mov di, offset figure_right_sides_2_1
                    jmp @continue_right_sides_figure_check

                @figure_right_sides_2_2:
                    mov cx, figure_right_sides_length_2_2
                    mov di, offset figure_right_sides_2_2
                    jmp @continue_right_sides_figure_check

            @check_right_sides_figure_3:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_right_sides_3_1
                cmp rotate_pos_figure, 2
                je @figure_right_sides_3_2
                cmp rotate_pos_figure, 3
                je @figure_right_sides_3_1
                cmp rotate_pos_figure, 4
                je @figure_right_sides_3_2

                @figure_right_sides_3_1:
                    mov cx, figure_right_sides_length_3_1
                    mov di, offset figure_right_sides_3_1
                    jmp @continue_right_sides_figure_check

                @figure_right_sides_3_2:
                    mov cx, figure_right_sides_length_3_2
                    mov di, offset figure_right_sides_3_2
                    jmp @continue_right_sides_figure_check

            @check_right_sides_figure_4:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_right_sides_4_1
                cmp rotate_pos_figure, 2
                je @figure_right_sides_4_2
                cmp rotate_pos_figure, 3
                je @figure_right_sides_4_3
                cmp rotate_pos_figure, 4
                je @figure_right_sides_4_4

                @figure_right_sides_4_1:
                    mov cx, figure_right_sides_length_4_1
                    mov di, offset figure_right_sides_4_1
                    jmp @continue_right_sides_figure_check

                @figure_right_sides_4_2:
                    mov cx, figure_right_sides_length_4_2
                    mov di, offset figure_right_sides_4_2
                    jmp @continue_right_sides_figure_check

                @figure_right_sides_4_3:
                    mov cx, figure_right_sides_length_4_3
                    mov di, offset figure_right_sides_4_3
                    jmp @continue_right_sides_figure_check

                @figure_right_sides_4_4:
                    mov cx, figure_right_sides_length_4_4
                    mov di, offset figure_right_sides_4_4
                    jmp @continue_right_sides_figure_check

            @check_right_sides_figure_5:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_right_sides_5_1
                cmp rotate_pos_figure, 2
                je @figure_right_sides_5_2
                cmp rotate_pos_figure, 3
                je @figure_right_sides_5_3
                cmp rotate_pos_figure, 4
                je @figure_right_sides_5_4

                @figure_right_sides_5_1:
                    mov cx, figure_right_sides_length_5_1
                    mov di, offset figure_right_sides_5_1
                    jmp @continue_right_sides_figure_check

                @figure_right_sides_5_2:
                    mov cx, figure_right_sides_length_5_2
                    mov di, offset figure_right_sides_5_2
                    jmp @continue_right_sides_figure_check

                @figure_right_sides_5_3:
                    mov cx, figure_right_sides_length_5_3
                    mov di, offset figure_right_sides_5_3
                    jmp @continue_right_sides_figure_check

                @figure_right_sides_5_4:
                    mov cx, figure_right_sides_length_5_4
                    mov di, offset figure_right_sides_5_4
                    jmp @continue_right_sides_figure_check

            @check_right_sides_figure_6:
                ; Вычисляем позицию
                mov cx, figure_right_sides_length_6
                mov di, offset figure_right_sides_6
                jmp @continue_right_sides_figure_check

            @check_right_sides_figure_7:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_right_sides_7_1
                cmp rotate_pos_figure, 2
                je @figure_right_sides_7_2
                cmp rotate_pos_figure, 3
                je @figure_right_sides_7_3
                cmp rotate_pos_figure, 4
                je @figure_right_sides_7_4

                @figure_right_sides_7_1:
                    mov cx, figure_right_sides_length_7_1
                    mov di, offset figure_right_sides_7_1
                    jmp @continue_right_sides_figure_check

                @figure_right_sides_7_2:
                    mov cx, figure_right_sides_length_7_2
                    mov di, offset figure_right_sides_7_2
                    jmp @continue_right_sides_figure_check

                @figure_right_sides_7_3:
                    mov cx, figure_right_sides_length_7_3
                    mov di, offset figure_right_sides_7_3
                    jmp @continue_right_sides_figure_check

                @figure_right_sides_7_4:
                    mov cx, figure_right_sides_length_7_4
                    mov di, offset figure_right_sides_7_4
                    jmp @continue_right_sides_figure_check

            @check_right_sides_figure_8:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_right_sides_8_1
                cmp rotate_pos_figure, 2
                je @figure_right_sides_8_2
                cmp rotate_pos_figure, 3
                je @figure_right_sides_8_3
                cmp rotate_pos_figure, 4
                je @figure_right_sides_8_4

                @figure_right_sides_8_1:
                    mov cx, figure_right_sides_length_8_1
                    mov di, offset figure_right_sides_8_1
                    jmp @continue_right_sides_figure_check

                @figure_right_sides_8_2:
                    mov cx, figure_right_sides_length_8_2
                    mov di, offset figure_right_sides_8_2
                    jmp @continue_right_sides_figure_check

                @figure_right_sides_8_3:
                    mov cx, figure_right_sides_length_8_3
                    mov di, offset figure_right_sides_8_3
                    jmp @continue_right_sides_figure_check

                @figure_right_sides_8_4:
                    mov cx, figure_right_sides_length_8_4
                    mov di, offset figure_right_sides_8_4
                    jmp @continue_right_sides_figure_check

            @check_right_sides_figure_9:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_right_sides_9_1
                cmp rotate_pos_figure, 2
                je @figure_right_sides_9_2
                cmp rotate_pos_figure, 3
                je @figure_right_sides_9_1
                cmp rotate_pos_figure, 4
                je @figure_right_sides_9_2

                @figure_right_sides_9_1:
                    mov cx, figure_right_sides_length_9_1
                    mov di, offset figure_right_sides_9_1
                    jmp @continue_right_sides_figure_check

                @figure_right_sides_9_2:
                    mov cx, figure_right_sides_length_9_2
                    mov di, offset figure_right_sides_9_2
                    jmp @continue_right_sides_figure_check

            @check_right_sides_figure_10:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_right_sides_10_1
                cmp rotate_pos_figure, 2
                je @figure_right_sides_10_2
                cmp rotate_pos_figure, 3
                je @figure_right_sides_10_1
                cmp rotate_pos_figure, 4
                je @figure_right_sides_10_2

                @figure_right_sides_10_1:
                    mov cx, figure_right_sides_length_10_1
                    mov di, offset figure_right_sides_10_1
                    jmp @continue_right_sides_figure_check

                @figure_right_sides_10_2:
                    mov cx, figure_right_sides_length_10_2
                    mov di, offset figure_right_sides_10_2
                    jmp @continue_right_sides_figure_check

            @check_right_sides_figure_11:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_right_sides_11_1
                cmp rotate_pos_figure, 2
                je @figure_right_sides_11_2
                cmp rotate_pos_figure, 3
                je @figure_right_sides_11_3
                cmp rotate_pos_figure, 4
                je @figure_right_sides_11_4

                @figure_right_sides_11_1:
                    mov cx, figure_right_sides_length_11_1
                    mov di, offset figure_right_sides_11_1
                    jmp @continue_right_sides_figure_check

                @figure_right_sides_11_2:
                    mov cx, figure_right_sides_length_11_2
                    mov di, offset figure_right_sides_11_2
                    jmp @continue_right_sides_figure_check

                @figure_right_sides_11_3:
                    mov cx, figure_right_sides_length_11_3
                    mov di, offset figure_right_sides_11_3
                    jmp @continue_right_sides_figure_check

                @figure_right_sides_11_4:
                    mov cx, figure_right_sides_length_11_4
                    mov di, offset figure_right_sides_11_4
                    jmp @continue_right_sides_figure_check

            @continue_right_sides_figure_check:
            call help_check_sides_figure

            ret
        check_right_sides_figure endp

        ; Вспомогательная для проверки и установки флага сторон
        help_check_crash_and_set_stop_move_flag proc
            ; Устанавливаем откуда читать
            mov si, ax
            mov ax, es:[si]

            ; Если дно
            cmp ah, color_glass
            je @set_stop_move_flag

            ; Если фигура
            mov si, offset colors
            xor ch, ch ; так надо
            mov cl, colors_len
            check_colors_loop_sides:
                cmp ah, [si]
                je @set_stop_move_flag
                inc si
                loop check_colors_loop_sides

            jmp @end_check_sides

            @set_stop_move_flag:
                mov stop_move_flag, 1

            @end_check_sides:

            ret
        help_check_crash_and_set_stop_move_flag endp

        ; Вспомогательная дичь
        help_check_sides_figure proc
            l_check_sides_figure:
                push cx
                call help_check_cells
                call help_check_crash_and_set_stop_move_flag
                pop cx
                cmp stop_move_flag, 1
                je @end_help_check_sides
                loop l_check_sides_figure

            @end_help_check_sides:

            ret
        help_check_sides_figure endp

        check_rotate_figure proc
            ; Получим проверяемый ячейки
            cmp current_figure, 1
            je @check_rotate_figure_1
            cmp current_figure, 2
            je @check_rotate_figure_2
            cmp current_figure, 3
            je @check_rotate_figure_3
            cmp current_figure, 4
            je @check_rotate_figure_4
            cmp current_figure, 5
            je @check_rotate_figure_5
            cmp current_figure, 6
            je @check_rotate_figure_6
            cmp current_figure, 7
            je @check_rotate_figure_7
            cmp current_figure, 8
            je @check_rotate_figure_8
            cmp current_figure, 9
            je @check_rotate_figure_9
            cmp current_figure, 10
            je @check_rotate_figure_10
            cmp current_figure, 11
            je @check_rotate_figure_11

            @check_rotate_figure_1:
                ; Вычисляем позицию
                mov cx, figure_rotate_length_1
                mov di, offset figure_rotate_1
                jmp @continue_rotate_figure_check

            @check_rotate_figure_2:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_rotate_2_1
                cmp rotate_pos_figure, 2
                je @figure_rotate_2_2
                cmp rotate_pos_figure, 3
                je @figure_rotate_2_1
                cmp rotate_pos_figure, 4
                je @figure_rotate_2_2

                @figure_rotate_2_1:
                    mov cx, figure_rotate_length_2_1
                    mov di, offset figure_rotate_2_1
                    jmp @continue_rotate_figure_check

                @figure_rotate_2_2:
                    mov cx, figure_rotate_length_2_2
                    mov di, offset figure_rotate_2_2
                    jmp @continue_rotate_figure_check

            @check_rotate_figure_3:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_rotate_3_1
                cmp rotate_pos_figure, 2
                je @figure_rotate_3_2
                cmp rotate_pos_figure, 3
                je @figure_rotate_3_1
                cmp rotate_pos_figure, 4
                je @figure_rotate_3_2

                @figure_rotate_3_1:
                    mov cx, figure_rotate_length_3_1
                    mov di, offset figure_rotate_3_1
                    jmp @continue_rotate_figure_check

                @figure_rotate_3_2:
                    mov cx, figure_rotate_length_3_2
                    mov di, offset figure_rotate_3_2
                    jmp @continue_rotate_figure_check

            @check_rotate_figure_4:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_rotate_4_1
                cmp rotate_pos_figure, 2
                je @figure_rotate_4_2
                cmp rotate_pos_figure, 3
                je @figure_rotate_4_3
                cmp rotate_pos_figure, 4
                je @figure_rotate_4_4

                @figure_rotate_4_1:
                    mov cx, figure_rotate_length_4_1
                    mov di, offset figure_rotate_4_1
                    jmp @continue_rotate_figure_check

                @figure_rotate_4_2:
                    mov cx, figure_rotate_length_4_2
                    mov di, offset figure_rotate_4_2
                    jmp @continue_rotate_figure_check

                @figure_rotate_4_3:
                    mov cx, figure_rotate_length_4_3
                    mov di, offset figure_rotate_4_3
                    jmp @continue_rotate_figure_check

                @figure_rotate_4_4:
                    mov cx, figure_rotate_length_4_4
                    mov di, offset figure_rotate_4_4
                    jmp @continue_rotate_figure_check

            @check_rotate_figure_5:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_rotate_5_1
                cmp rotate_pos_figure, 2
                je @figure_rotate_5_2
                cmp rotate_pos_figure, 3
                je @figure_rotate_5_3
                cmp rotate_pos_figure, 4
                je @figure_rotate_5_4

                @figure_rotate_5_1:
                    mov cx, figure_rotate_length_5_1
                    mov di, offset figure_rotate_5_1
                    jmp @continue_rotate_figure_check

                @figure_rotate_5_2:
                    mov cx, figure_rotate_length_5_2
                    mov di, offset figure_rotate_5_2
                    jmp @continue_rotate_figure_check

                @figure_rotate_5_3:
                    mov cx, figure_rotate_length_5_3
                    mov di, offset figure_rotate_5_3
                    jmp @continue_rotate_figure_check

                @figure_rotate_5_4:
                    mov cx, figure_rotate_length_5_4
                    mov di, offset figure_rotate_5_4
                    jmp @continue_rotate_figure_check

            @check_rotate_figure_6:
                ; Вычисляем позицию
                mov cx, figure_rotate_length_6
                mov di, offset figure_rotate_6
                jmp @continue_rotate_figure_check

            @check_rotate_figure_7:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_rotate_7_1
                cmp rotate_pos_figure, 2
                je @figure_rotate_7_2
                cmp rotate_pos_figure, 3
                je @figure_rotate_7_3
                cmp rotate_pos_figure, 4
                je @figure_rotate_7_4

                @figure_rotate_7_1:
                    mov cx, figure_rotate_length_7_1
                    mov di, offset figure_rotate_7_1
                    jmp @continue_rotate_figure_check

                @figure_rotate_7_2:
                    mov cx, figure_rotate_length_7_2
                    mov di, offset figure_rotate_7_2
                    jmp @continue_rotate_figure_check

                @figure_rotate_7_3:
                    mov cx, figure_rotate_length_7_3
                    mov di, offset figure_rotate_7_3
                    jmp @continue_rotate_figure_check

                @figure_rotate_7_4:
                    mov cx, figure_rotate_length_7_4
                    mov di, offset figure_rotate_7_4
                    jmp @continue_rotate_figure_check

            @check_rotate_figure_8:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_rotate_8_1
                cmp rotate_pos_figure, 2
                je @figure_rotate_8_2
                cmp rotate_pos_figure, 3
                je @figure_rotate_8_3
                cmp rotate_pos_figure, 4
                je @figure_rotate_8_4

                @figure_rotate_8_1:
                    mov cx, figure_rotate_length_8_1
                    mov di, offset figure_rotate_8_1
                    jmp @continue_rotate_figure_check

                @figure_rotate_8_2:
                    mov cx, figure_rotate_length_8_2
                    mov di, offset figure_rotate_8_2
                    jmp @continue_rotate_figure_check

                @figure_rotate_8_3:
                    mov cx, figure_rotate_length_8_3
                    mov di, offset figure_rotate_8_3
                    jmp @continue_rotate_figure_check

                @figure_rotate_8_4:
                    mov cx, figure_rotate_length_8_4
                    mov di, offset figure_rotate_8_4
                    jmp @continue_rotate_figure_check

            @check_rotate_figure_9:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_rotate_9_1
                cmp rotate_pos_figure, 2
                je @figure_rotate_9_2
                cmp rotate_pos_figure, 3
                je @figure_rotate_9_1
                cmp rotate_pos_figure, 4
                je @figure_rotate_9_2

                @figure_rotate_9_1:
                    mov cx, figure_rotate_length_9_1
                    mov di, offset figure_rotate_9_1
                    jmp @continue_rotate_figure_check

                @figure_rotate_9_2:
                    mov cx, figure_rotate_length_9_2
                    mov di, offset figure_rotate_9_2
                    jmp @continue_rotate_figure_check

            @check_rotate_figure_10:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_rotate_10_1
                cmp rotate_pos_figure, 2
                je @figure_rotate_10_2
                cmp rotate_pos_figure, 3
                je @figure_rotate_10_1
                cmp rotate_pos_figure, 4
                je @figure_rotate_10_2

                @figure_rotate_10_1:
                    mov cx, figure_rotate_length_10_1
                    mov di, offset figure_rotate_10_1
                    jmp @continue_rotate_figure_check

                @figure_rotate_10_2:
                    mov cx, figure_rotate_length_10_2
                    mov di, offset figure_rotate_10_2
                    jmp @continue_rotate_figure_check

            @check_rotate_figure_11:
                ; Вычисляем позицию
                cmp rotate_pos_figure, 1
                je @figure_rotate_11_1
                cmp rotate_pos_figure, 2
                je @figure_rotate_11_2
                cmp rotate_pos_figure, 3
                je @figure_rotate_11_3
                cmp rotate_pos_figure, 4
                je @figure_rotate_11_4

                @figure_rotate_11_1:
                    mov cx, figure_rotate_length_11_1
                    mov di, offset figure_rotate_11_1
                    jmp @continue_rotate_figure_check

                @figure_rotate_11_2:
                    mov cx, figure_rotate_length_11_2
                    mov di, offset figure_rotate_11_2
                    jmp @continue_rotate_figure_check

                @figure_rotate_11_3:
                    mov cx, figure_rotate_length_11_3
                    mov di, offset figure_rotate_11_3
                    jmp @continue_rotate_figure_check

                @figure_rotate_11_4:
                    mov cx, figure_rotate_length_11_4
                    mov di, offset figure_rotate_11_4
                    jmp @continue_rotate_figure_check

            @continue_rotate_figure_check:
            call help_check_rotate_figure

            ret

            ; Вспомогательная для проверки и установки флага отмены поворота
            help_check_crash_and_set_rotate_flag proc
                ; Устанавливаем откуда читать
                mov si, ax
                mov ax, es:[si]

                ; Если дно
                cmp ah, color_glass
                je @set_rotate_flag

                ; Если фигура
                mov si, offset colors
                xor ch, ch ; так надо
                mov cl, colors_len
                check_colors_loop_rotate:
                    cmp ah, [si]
                    je @set_rotate_flag
                    inc si
                    loop check_colors_loop_rotate

                jmp @end_check_rotate

                @set_rotate_flag:
                    mov stop_rotate_flag, 1

                @end_check_rotate:

                ret
            help_check_crash_and_set_rotate_flag endp

            ; Вспомогательная дичь
            help_check_rotate_figure proc
                l_check_rotate_figure:
                    push cx
                    call help_check_cells
                    call help_check_crash_and_set_rotate_flag
                    pop cx
                    cmp stop_rotate_flag, 1
                    je @end_help_check_rotate
                    loop l_check_rotate_figure

                @end_help_check_rotate:

                ret
            help_check_rotate_figure endp
        check_rotate_figure endp

        ; По окончанию в ax значение из буфера
        get_value_from_buff proc
            ; Устанавливаем откуда читать
            mov ax, video_memory
            mov es, ax

            ; Вычислим позицию начала проверки
            mov ax, row_size
            mov bx, check_cell_row
            mul bx ; получили строку
            add ax, check_cell_col ; здесь позицию в строке
            mul symb_size ; символ занимает 2 байта (теперь в ax нужная позиция)

            mov si, ax
            mov ax, es:[si]

            ret
        get_value_from_buff endp

        check_full_row proc
            mov ax, down_pos_glass
            dec ax ; поднялись на первую строку днища
            mov check_cell_row, ax
            mov ax, start_pos_glass
            add ax, 2 ; сдвинулись на первую ячейку
            mov check_cell_col, ax

            mov cx, 0 ; счётчик пробега по строке
            mov bp, 0 ; когда закончить ?
            mov dropped_cells, 0 ; сколько сдвинули уже вниз ?

            @continue_check_full_row:
                mov ax, width_glass
                sub ax, 2 ; т.к. стенки стоят на дне
                cmp cx, ax
                je @new_row_and_clean

                call get_value_from_buff ; после вызова в ax значение буфера

                ; Сдвинулись сразу по строке
                add check_cell_col, 2

                inc cx

                cmp ah, 00h
                je @new_row
                jne @continue_check_full_row

            @end_check_full_row:

            ret

            @new_row:
                ; Сколько строк нужно проверить ?
                mov ax, depth_glass
                sub ax, top_pos_glass
                cmp bp, ax
                je @end_check_full_row

                dec check_cell_row ; поднялись на строку выше
                ; Вернулись на начальную позицию колонки
                sub check_cell_col, cx
                sub check_cell_col, cx

                xor cx, cx
                inc bp
                jmp @continue_check_full_row

            @new_row_and_clean:
                mov ax, width_glass
                sub ax, 2 ; т.к. стенки стоят на дне
                mul symb_size ; т.к. ширина в клетках фигуры
                mov cx, ax
                mov ax, check_cell_row
                mov row, ax
                mov ax, check_cell_col
                sub ax, 1 ; сдвинулись на самую правую ячейку для затирки
                mov col, ax
                l_clean_row:
                    mov al, color
                    push ax
                    mov color, 00h
                    call draw
                    dec col
                    pop ax
                    mov color, al
                    loop l_clean_row

                inc col ; вернулись на самую левую ячейку фигуры

                @dropping_next_cells_in_col:
                push check_cell_row ; запомнили позицию стираемой строки

                ; Дальше нам нужно сдвинуть все строки, которые выше вниз
                @continue_dropping_cells_in_col:
                dec check_cell_row

                mov ax, check_cell_row
                mov row, ax

                mov ax, col
                mov check_cell_col, ax

                call get_value_from_buff ; взяли ячейку над пустой строкой

                mov drop_cell_color, ah ; сохраним её цвет

                inc check_cell_row
                call get_value_from_buff
                cmp ah, 00h
                je @drop_cell
                jne @next_cells_in_col
                ; Теперь вычислим позицию куда её надо отрисовать ниже, нащупаем дно
                
                @drop_cell:
                    ; Стираем
                    mov al, color
                    push ax

                    mov color, 00h
                    call draw
                    inc col
                    call draw
                    dec col

                    ; Теперь нужно отрисовать ниже
                    inc row
                    mov al, drop_cell_color
                    mov color, al
                    call draw
                    inc col
                    call draw
                    dec col

                    dec check_cell_row ; раз удалили, то поднимемся выше

                    pop ax
                    mov color, al
                    jmp @continue_dropping_cells_in_col

                @next_cells_in_col:
                    mov ax, width_glass
                    sub ax, 2 ; т.к. стенки стоят на дне
                    cmp dropped_cells, ax
                    je @end_clean_full_row

                    pop ax
                    mov check_cell_row, ax
                    add col, 2

                    inc dropped_cells
                    jmp @dropping_next_cells_in_col

                @end_clean_full_row:
                pop ax ; просто убрали из стека лишнее
                inc score ; счёт увеличили =)

                jmp check_full_row ; пойдём проверять дальше полные строки, после первого удаления
        check_full_row endp

        set_handler_keyboard09h proc
            mov ah, 35h ; получаем вектор
            mov al, 09h
            int 21h

            mov word ptr old_handler_keyboard09h, bx ; смещение
            mov word ptr old_handler_keyboard09h + 2, es ; сегмент

            mov ah, 25h ; ставим себя на обработчик
            mov dx, offset new_handler_keyboard09h
            int 21h

            ret
        set_handler_keyboard09h endp

        new_handler_keyboard09h:
            pushf
            push ax
            push bx

            in al, 60h ; читать ключ
            mov current_symbol_key, al
            in al, 61h ; взять значениe порта управления клавиатурой
            mov ah, al ; сохранить его
            or al, 80h ; установить бит разрешения для клавиатуры
            out 61h, al ; и вывести его в управляющий порт
            xchg ah, al ; извлечь исходное значение порта
            out 61h, al ; и записать его обратно
            mov al, 20h ; послать сигнал "конец прерывания"
            out 20h, al ; контроллеру прерываний 8259

            pop bx
            pop ax
            popf

            ; Управление
            cmp current_symbol_key, 4bh
            je @l_arrow
            cmp current_symbol_key, 4dh
            je @r_arrow
            cmp current_symbol_key, 48h
            je @u_arrow
            cmp current_symbol_key, 50h
            je @d_arrow

            ; Повернуть фигуру
            cmp current_symbol_key, 2ch
            je @set_rotate_figure_flag

            ; Уронить фигуру
            cmp current_symbol_key, 39h
            je @set_drop_figure_flag_on

            ; Увеличим скорость
            cmp current_symbol_key, 0Dh
            je @set_speed_inc_flag

            ; Уменьшим скорость
            cmp current_symbol_key, 0Ch
            je @set_speed_dec_flag

            ; Стоп (фигура не падает)
            cmp current_symbol_key, 1fh
            je @set_stop_game_flag

            ; Пауза (из неё можно выйти, заверщить игру, начать новую игру)
            cmp current_symbol_key, 19h
            je @set_pause_game_flag

            ; Новая игра
            cmp current_symbol_key, 31h
            je @set_new_game_flag

            ; Выходим из игры
            cmp current_symbol_key, 01h
            je @set_exit_flag

            jmp @iret

            @u_arrow:
                mov up_click, 1
                jmp @iret
            @d_arrow:
                mov down_click, 1
                jmp @iret
            @l_arrow:
                mov left_click, 1
                jmp @iret
            @r_arrow:
                mov right_click, 1
                jmp @iret

            @set_rotate_figure_flag:
                mov rotate_figure_flag, 1
                jmp @iret

            @set_drop_figure_flag_on:
                mov drop_figure_flag, 1
                jmp @iret

            @set_speed_inc_flag:
                mov speed_inc_flag, 1
                jmp @iret

            @set_speed_dec_flag:
                mov speed_dec_flag, 1
                jmp @iret

            @set_stop_game_flag:
                cmp stop_game_flag, 0
                je @set_stop_game_flag_on

                cmp stop_game_flag, 1
                je @set_stop_game_flag_off

                @set_stop_game_flag_on:
                    mov stop_game_flag, 1
                    jmp @iret

                @set_stop_game_flag_off:
                    mov stop_game_flag, 0
                    jmp @iret

            @set_pause_game_flag:
                cmp pause_game_flag, 0
                je @set_pause_game_flag_on

                cmp pause_game_flag, 1
                je @set_pause_game_flag_off

                @set_pause_game_flag_on:
                    mov pause_game_flag, 1
                    jmp @iret

                @set_pause_game_flag_off:
                    mov pause_game_flag, 0
                    ; Дальше нам нужно сбросить все клавиши, которые нажали во время паузы
                    call drop_flags
                    jmp @iret

            @set_new_game_flag:
                mov new_game_flag, 1
                jmp @iret

            @set_exit_flag:
                mov exit_flag, 1

            @iret:
                mov current_symbol_key, 0
                iret

        set_handler_timer08h proc
            mov ah, 35h ; получаем вектор
            mov al, 08h
            int 21h

            mov word ptr old_handler_timer08h, bx ; смещение
            mov word ptr old_handler_timer08h + 2, es ; сегмент

            mov ah, 25h ; ставим себя на обработчик
            mov dx, offset new_handler_timer08h
            int 21h

            ret
        set_handler_timer08h endp

        new_handler_timer08h:
            push ax
            mov al, speed
            cmp timer_tick, al
            pop ax
            je @one_second
            inc timer_tick
            @continue_timer:
            jmp cs:old_handler_timer08h

            @one_second:
                mov timer_tick, 0
                mov move_down_flag, 1 ; пора сместить фигуру ниже
                jmp @continue_timer

        drop_flags proc
            mov up_click, 0
            mov down_click, 0
            mov left_click, 0
            mov right_click, 0
            mov rotate_figure_flag, 0
            mov drop_figure_flag, 0
            mov speed_inc_flag, 0
            mov speed_dec_flag, 0

            ret
        drop_flags endp

        ; в bx - длительность, в di - частота
        make_sound proc  
            mov al, 0b6h ; записать в регистр режим таймера
            out 43h, al
            mov ax, 4f38h ; 1331000/частота
            mov dx, 14h ; делитель времени
            div di
            out 42h, al ; записать младший байт счетчика таймера
            mov al, ah
            out 42h, al ; записать старший байт счетчика таймера
            in al, 61h ; считать текущую установку порта
            mov ah, al ; и сохранить ее в регистре АН
            or al, 3h ; включить динамик
            out 61h, al

            _ms_wait:
                mov cx, 2800 ; выждать 10 мс
            _ms_spkr_on:
                loop _ms_spkr_on

            dec bx ; счетчик длительности исчерпан ?
            jnz _ms_wait ; нет, продолжить звучание
            mov al, ah ; да, восстановить исходную установку порта
            out 61h, al

            ret
        make_sound endp

        set_cursor_pos proc
            push dx

            mov ah, 02h
            mov bh, 00h
            mov dh, cursor_pos_row
            mov dl, cursor_pos_col
            int 10h

            pop dx

            ret
        set_cursor_pos endp

        ; Скроем курсор
        remove_cursor proc
            mov ah, 02h
            mov bh, 00h
            mov dh, 25
            mov dl, 0
            int 10h

            ret
        remove_cursor endp

        ; Строка должна быть в dx
        print_string proc
            call set_cursor_pos

            mov ah, 09h
            int 21h

            call remove_cursor

            ret
        print_string endp

        ; В cx - переводимое число
        hex_to_decimal_and_print proc
            mov si, offset buffer

            ; Зачистка от предыдущих значений
            push cx

            mov cx, buffer_len
            mov ax, '$'
            clean_buffer:
                mov [si], ax
                inc si
                loop clean_buffer

            pop cx

            mov ax, cx ; cx - нужное число
            mov bx, 10

            @getting:
                mov dx, 0 ; clear dx prior to dividing dx:ax by bx
                div bx ; div ax/10
                add dx, 48 ; add 48 to remainder to get ASCII character of number
                dec si ; store characters in reverse order
                mov [si], dl
                cmp ax, 0
                jz @end_diving ; if ax = 0 - end of procedure
                jmp @getting ; else repeat

            @end_diving:
            mov dx, offset si
            call print_string

            ret
        hex_to_decimal_and_print endp

        write_help_text proc
            mov cursor_pos_row, 0
            mov cursor_pos_col, 0
            mov dx, offset help_text
            call print_string

            ret
        write_help_text endp

        ; Поставили строку "NEXT:"
        write_next_text proc
            mov cursor_pos_row, 1
            mov cursor_pos_col, 62
            mov dx, offset figure_next_text
            call print_string

            ret
        write_next_text endp

        write_speed_text proc
            mov cursor_pos_row, 23
            mov cursor_pos_col, 0
            mov dx, offset speed_text
            call print_string

            mov cursor_pos_col, 7
            ; Отобразим адекватную скорость, а не тики в секунду
            mov al, default_speed
            sub al, speed
            xor ch, ch ; так надо
            mov cl, al
            call hex_to_decimal_and_print

            ret
        write_speed_text endp

        write_score_text proc
            mov cursor_pos_row, 24
            mov cursor_pos_col, 0
            mov dx, offset score_text
            call print_string

            mov cursor_pos_col, 7
            xor ch, ch ; так надо
            mov cl, score
            call hex_to_decimal_and_print

            ret
        write_score_text endp

        draw_figures_statistic proc
            mov ah, current_figure
            mov al, rotate_pos_figure
            mov bl, color
            push ax
            push bx

            mov rotate_pos_figure, 1

            mov current_row, 8
            mov current_col, 57
            mov color, 11h
            mov current_figure, 1
            call draw_figure_number
            mov cursor_pos_row, 9
            mov cursor_pos_col, 57
            xor ch, ch
            mov cl, figure_1_time
            call hex_to_decimal_and_print

            mov current_row, 8
            mov current_col, 63
            mov color, 22h
            mov current_figure, 2
            call draw_figure_number
            mov cursor_pos_row, 9
            mov cursor_pos_col, 63
            xor ch, ch
            mov cl, figure_2_time
            call hex_to_decimal_and_print

            mov current_row, 8
            mov current_col, 71
            mov color, 33h
            mov current_figure, 3
            call draw_figure_number
            mov cursor_pos_row, 9
            mov cursor_pos_col, 71
            xor ch, ch
            mov cl, figure_3_time
            call hex_to_decimal_and_print

            mov current_row, 11
            mov current_col, 57
            mov color, 55h
            mov current_figure, 5
            call draw_figure_number
            mov cursor_pos_row, 14
            mov cursor_pos_col, 57
            xor ch, ch
            mov cl, figure_5_time
            call hex_to_decimal_and_print

            mov current_row, 11
            mov current_col, 63
            mov color, 66h
            mov current_figure, 4
            call draw_figure_number
            mov cursor_pos_row, 14
            mov cursor_pos_col, 63
            xor ch, ch
            mov cl, figure_4_time
            call hex_to_decimal_and_print

            mov current_row, 11
            mov current_col, 71
            mov color, 77h
            mov current_figure, 7
            call draw_figure_number
            mov cursor_pos_row, 14
            mov cursor_pos_col, 71
            xor ch, ch
            mov cl, figure_7_time
            call hex_to_decimal_and_print

            mov rotate_pos_figure, 2
            mov current_row, 16
            mov current_col, 57
            mov color, 11h
            mov current_figure, 10
            mov rotate_pos_figure, 2
            call draw_figure_number
            mov cursor_pos_row, 19
            mov cursor_pos_col, 57
            xor ch, ch
            mov cl, figure_10_time
            call hex_to_decimal_and_print

            mov current_row, 16
            mov current_col, 63
            mov color, 22h
            mov current_figure, 8
            mov rotate_pos_figure, 1
            call draw_figure_number
            mov cursor_pos_row, 19
            mov cursor_pos_col, 63
            xor ch, ch
            mov cl, figure_8_time
            call hex_to_decimal_and_print

            mov current_row, 16
            mov current_col, 71
            mov color, 33h
            mov current_figure, 9
            mov rotate_pos_figure, 2
            call draw_figure_number
            mov cursor_pos_row, 19
            mov cursor_pos_col, 71
            xor ch, ch
            mov cl, figure_9_time
            call hex_to_decimal_and_print

            mov current_row, 21
            mov current_col, 57
            mov color, 55h
            mov current_figure, 6
            mov rotate_pos_figure, 1
            call draw_figure_number
            mov cursor_pos_row, 23
            mov cursor_pos_col, 57
            xor ch, ch
            mov cl, figure_6_time
            call hex_to_decimal_and_print

            mov current_row, 21
            mov current_col, 65
            mov color, 66h
            mov current_figure, 11
            mov rotate_pos_figure, 2
            call draw_figure_number
            mov cursor_pos_row, 24
            mov cursor_pos_col, 65
            xor ch, ch
            mov cl, figure_11_time
            call hex_to_decimal_and_print

            pop bx
            pop ax
            mov current_figure, ah
            mov rotate_pos_figure, al
            mov color, bl

            ret
        draw_figures_statistic endp

        clean_statistics proc
            mov score, 0
            call write_score_text

            mov al, default_speed
            mov speed, al
            call write_speed_text

            mov figure_1_time, 0
            mov figure_2_time, 0
            mov figure_3_time, 0
            mov figure_4_time, 0
            mov figure_5_time, 0
            mov figure_6_time, 0
            mov figure_7_time, 0
            mov figure_8_time, 0
            mov figure_9_time, 0
            mov figure_10_time, 0
            mov figure_11_time, 0

            ; Подсчитать нам нужно предсказанную фигуру в этом случае
            mov al, predicted_figure_num
            mov current_figure, al

            mov extreme_check_flag, 1
            jmp @extreme_check

            @end_extreme_check:
            mov extreme_check_flag, 0

            ret
        clean_statistics endp

        write_end_game_text proc
            mov cursor_pos_row, 15
            mov cursor_pos_col, 8
            mov dx, offset end_game_text
            call print_string

            ret
        write_end_game_text endp

        write_end_game_text_clean proc
            mov cursor_pos_row, 15
            mov cursor_pos_col, 8
            mov dx, offset end_game_text_clean
            call print_string

            ret
        write_end_game_text_clean endp

        ; Функция DOS завершения программы + возврат обработчиков + очистка экрана
        exit:
            call set_video_mode ; очистка

            cli
            push 0000h
            pop es
            mov bx, 0020h ; 8 * 4 = 32 в десятичной
            mov ax, word ptr old_handler_timer08h
            mov es:[bx], ax
            mov ax, word ptr old_handler_timer08h + 2
            mov es:[bx + 2], ax
            mov bx, 0024h ; 9 * 4 = 36 в десятичной
            mov ax, word ptr old_handler_keyboard09h
            mov es:[bx], ax
            mov ax, word ptr old_handler_keyboard09h + 2
            mov es:[bx + 2], ax
            sti

            @terminate_process: ; для отладки
                mov ah, 4ch
                int 21h
    end entry