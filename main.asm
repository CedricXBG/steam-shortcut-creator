global _start
extern gtk_init, gtk_window_new, gtk_window_set_title, gtk_window_set_default_size
extern g_signal_connect_data, gtk_widget_show_all, gtk_main, gtk_main_quit, gtk_button_new_with_label
extern gtk_container_add, gtk_entry_new, gtk_grid_new, gtk_grid_attach
extern gtk_widget_set_halign, gtk_widget_set_valign, exit, gtk_entry_get_text, puts
extern snprintf, curl_easy_init, curl_easy_setopt, curl_easy_perform, curl_easy_cleanup, strstr
extern fopen, fread, fclose, readlink, chmod, fwrite
extern gtk_message_dialog_new, gtk_dialog_run, gtk_widget_destroy, gtk_grid_set_row_spacing, gtk_grid_set_column_spacing
extern gtk_image_new_from_icon_name, gtk_entry_set_placeholder_text, gtk_settings_get_default, gtk_image_new_from_file
extern gtk_message_dialog_set_image, gtk_widget_show, gtk_widget_get_style_context, gtk_style_context_add_class
extern gtk_css_provider_new, gtk_css_provider_load_from_data, gdk_screen_get_default, gtk_style_context_add_provider_for_screen

section .data
	title: db "Steam Shortcut Creator", 0
	button_label: db "Create shortcut", 0
	signal_destroy: db "destroy", 0
	signal_clicked: db "clicked", 0

	url_format: db "https://store.steampowered.com/api/appdetails?appids=%s", 0
	key_name:   db 0x22, "name", 0x22, 0

	mode_w: db "w", 0

	self_exe: db "/proc/self/exe", 0
	desktop_fmt: db "%s/%s.desktop", 0
	window_width: dd 400
	window_height: dd 250

	template_content: db "[Desktop Entry] ", 10
			db "Name=%s", 10
			db "Comment=Play this game on Steam", 10
			db "Exec=steam steam://rungameid/%s", 10
			db "Icon=steam_icon_%s", 10
			db "Terminal=false", 10
			db "Type=Application", 10
			db "Categories=Game;", 10, 0

	fmt_plain: db "%s", 0
	msg_format_success: db "Shortcut created successfully for %s!", 0

	text_placeholder: db "Game AppID...", 0

	steam_icon_name: db "steam", 0

	icon_replace: db "steam_icon_%s", 0
	
	class_dialog_win: db "dialog-win", 0
	class_main_win: db "main-window", 0
	css_style: 	db "window.main-window { background-color: #1e1e2e; } ", 10
			db "window.main-window entry { border-radius: 8px; padding: 6px; background-color: #313244; color: #cdd6f4; border: 1px solid #45475a; } ", 10
			db "window.main-window entry:focus { border-color: #cba6f7; } ", 10
			db "window.main-window button { background-color: #89b4fa; color: #11111b; font-weight: bold; border-radius: 8px; padding: 8px; } ", 10
			db "window.main-window button:hover { background-color: #b4befe; } ", 0

section .bss
	url_buffer: resb 512
	response_buf: resb 65536 ; buffer for json res
	write_ptr: resq 1 ; pointer for libcurl
	game_name: resb 256 ; buffer for game name
	out_buf: resb 4096 ; final result
	appid_ptr: resq 1; appid pointer
	exe_path: resb 512
	desktop_path: resb 512
	out_len: resq 1
	confirmation_msg: resb 320
	main_window: resq 1
	icon_replace_buf: resb 128

section .text
_start:
	push rbp
	push r15
	push r14
	push r13
	push r12
	push rbx

	xor edi, edi
	xor esi, esi
	call gtk_init

	call apply_css

	xor edi, edi
	call gtk_window_new
	mov r13, rax ; R13 = window

	mov [rel main_window], r13
	
	; add main-window class
	mov rdi, r13 ; main window
	call gtk_widget_get_style_context ; fetch GtkStyleContext of window
	mov rdi, rax 			; 1st arg : style context
	lea rsi, [rel class_main_win] 	; 2nd arg : "main-window"
	call gtk_style_context_add_class ; add class

	mov rdi, r13
	mov esi, dword [rel window_width]
	mov edx, dword [rel window_height]
	call gtk_window_set_default_size

	mov rdi, r13
	lea rsi, [rel title]
	call gtk_window_set_title

	call gtk_grid_new
	mov rbx, rax ; RBX = grid pointer

	mov rdi, rbx ; grid
	mov rsi, 10 ; 10px column spacing
	call gtk_grid_set_column_spacing

	mov rdi, rbx ; grid
	mov rsi, 12 ; 12px row spacing
	call gtk_grid_set_row_spacing

	mov rdi, rbx ; grid
	mov esi, 3   ; GTK_ALIGN_CENTER (3)
	call gtk_widget_set_halign

	mov rdi, rbx ; grid
	mov esi, 3   ; GTK_ALIGN_CENTER (3)
	call gtk_widget_set_valign

	mov rdi, r13 ; window
	mov rsi, rbx ; grid
	call gtk_container_add ; add grid to window container

	lea rdi, [rel steam_icon_name]
	mov esi, 6 ; 48x48px
	call gtk_image_new_from_icon_name
	mov r15, rax ; R15 = steam icon pointer

	call gtk_entry_new
	mov r14, rax ; R14 = text entry pointer

	mov rdi, r14
	lea rsi, [rel text_placeholder]
	call gtk_entry_set_placeholder_text

	lea rdi, [rel button_label]
	call gtk_button_new_with_label
	mov r12, rax ; R12 = button pointer

	mov rdi, rbx ; grid
	mov rsi, r15 ; steam icon
	xor edx, edx ; left 0
	xor ecx, ecx ; top 0
	mov r8d, 1 ; width 1
	mov r9d, 1 ; height 1
	call gtk_grid_attach

	mov rdi, rbx ; grid
	mov rsi, r14 ; textbox entry 
	xor edx, edx ; left
	mov ecx, 1 ; top
	mov r8d, 1 ; 1 width
	mov r9d, 1 ; 1 height
	call gtk_grid_attach
	
	mov rdi, rbx ; 1st arg : grid
	mov rsi, r12 ; 2nd arg : button
	xor edx, edx   ; 3rd arg : left (column 0)
	mov ecx, 2 ; 4th arg : top (line 1)
	mov r8d, 1   ; 5th arg : width (takes 1 width)
	mov r9d, 1   ; 6th arg : height (takes 1 line)
	call gtk_grid_attach

	mov rdi, r12 ; button
	lea rsi, [rel signal_clicked]
	lea rdx, [rel on_button_clicked]
	mov rcx, r14 ; textbox
	xor r8d, r8d
	xor r9d, r9d
	call g_signal_connect_data

	mov rdi, r13
	lea rsi, [rel signal_destroy]
	lea rdx, [rel gtk_main_quit]
	xor ecx, ecx
	xor r8d, r8d
	xor r9d, r9d
	call g_signal_connect_data

	mov rdi, r13
	call gtk_widget_show_all

	call gtk_main

	xor edi, edi
	call exit

on_button_clicked:
	push rbp
	mov rbp, rsp
	push r12 ; dummy register to align stack
	push rbx

	; reset res ptr for every click
	lea rax, [rel response_buf]
	mov [rel write_ptr], rax
	mov byte [rax], 0
	
	mov rdi, rsi ; user_data
	call gtk_entry_get_text

	mov [rel appid_ptr], rax ; set appid pointer

	lea rdi, [rel url_buffer] ; destination buffer
	mov rsi, 512 ; max weight of buffer
	lea rdx, [rel url_format]
	mov rcx, rax ; fetched text from textbox
	xor eax, eax ; AL = 0 (no floating args for variadic)
	call snprintf

	call curl_easy_init
	test rax, rax
	jz .done
	mov rbx, rax ; RBX = handle CURL
	
	mov rdi, rbx ; 1st arg : handle CURL
	mov esi, 10002 ; 2nd arg : CURLOPT_URL
	lea rdx, [rel url_buffer] ; generated url pointer
	xor eax, eax
	call curl_easy_setopt

	mov rdi, rbx
	mov esi, 20011 ; CURLOPT_WRITEFUNCTION
	lea rdx, [rel write_callback]
	xor eax, eax
	call curl_easy_setopt

	mov rdi, rbx
	mov esi, 10001 ; CURLOPT_WRITEDATA
	lea rdx, [rel response_buf]
	xor eax, eax
	call curl_easy_setopt
	
	mov rdi, rbx
	call curl_easy_perform

	mov rdi, rbx
	call curl_easy_cleanup

	lea rdi, [rel response_buf]
	lea rsi, [rel key_name]
	call strstr
	test rax, rax
	jz .done ; exit if not found
	add rax, 6
	mov rsi, rax

.find_colon:
	lodsb
	test al, al ; if end of str then leave instead of going through all the memory lol
	jz .done
	cmp al, ':'
	jne .find_colon
.find_quote:
	lodsb
	test al, al ; same here
	jz .done
	cmp al, '"'
	jne .find_quote

	lea rdi, [rel game_name]

.copy_loop:
	lodsb
	test al, al
	jz .end_copy
	cmp al, '"'
	je .end_copy
	cmp al, '\'
	jne .store_char
	lodsb
	test al, al
	jz .end_copy
.store_char:
	mov [rdi], al
	inc rdi
	jmp .copy_loop

.end_copy:
	mov byte [rdi], 0 ; null byte

	call apply_template	

.done:
	pop rbx
	pop r12
	pop rbp
	ret

write_callback:
	push rbp
	mov rbp, rsp
	push r12
	push rbx

	mov rax, rsi
	imul rax, rdx ; rax = received data weight / rdx = number of elements
	test rax, rax
	jz .cb_done ; if 0 bytes received then we exit

	mov r12, rax

	mov rbx, [rel write_ptr]
	lea rdx, [rel response_buf]
	add rdx, 65535 ; limite = fin du buffer - 1 pour le null byte
	sub rdx, rbx ; espace restant
	cmp rax, rdx
	jbe .size_ok
	mov rax, rdx ; troncate if above than 64 Ko
	
.size_ok:
	test rax, rax
	jle .cb_done

	mov rcx, rax
	mov rsi, rdi
	mov rdi, rbx
	cld
	rep movsb ; copy byte per byte

	mov byte [rdi], 0
	mov [rel write_ptr], rdi

	mov rax, r12

.cb_done:
	pop rbx
	pop r12
	pop rbp
	ret

apply_template:
	push rbp
	mov rbp, rsp
	push r12
	push rbx

	lea rdi, [rel out_buf] ; destination = our out_buf
	mov rsi, 4096 ; max size
	lea rdx, [rel template_content] ; format = template file content
	lea rcx, [rel game_name] ; 1st %s : game name
	mov r8, [rel appid_ptr] ; 2nd %s : game appid
	mov r9, [rel appid_ptr] ; 3rd %s : also game appid
	xor eax, eax ; AL = 0 for variadic
	call snprintf
	cmp rax, 4095
	jbe .len_ok
	mov rax, 4095
.len_ok:
	mov [rel out_len], rax

	lea rdi, [rel self_exe]
	lea rsi, [rel exe_path]
	mov rdx, 511
	call readlink
	cmp rax, 0
	jl .err_template
	lea rdx, [rel exe_path]
	mov byte [rdx + rax], 0 ; readlink n'ajoute pas de null byte, faut le faire nous meme

	lea rdi, [rel exe_path]
	mov rsi, rax
	add rsi, rdi
.find_last_slash:
	cmp rsi, rdi
	jle .err_template
	dec rsi
	cmp byte [rsi], '/'
	jne .find_last_slash
	mov byte [rsi], 0

	lea rdi, [rel desktop_path]
	mov rsi, 512
	lea rdx, [rel desktop_fmt]
	lea rcx, [rel exe_path]
	lea r8, [rel game_name]
	xor eax, eax
	call snprintf

	lea rdi, [rel desktop_path]
	lea rsi, [rel mode_w]
	call fopen
	test rax, rax
	jz .err_template
	mov r12, rax

	lea rdi, [rel out_buf]
	mov rsi, 1
	mov rdx, [rel out_len]
	mov rcx, r12
	call fwrite

	mov rdi, r12
	call fclose

	lea rdi, [rel desktop_path]
	mov esi, 0o755
	call chmod

	call show_confirmation

.err_template:
	pop rbx
	pop r12
	pop rbp
	ret

show_confirmation:
	push rbp
	mov rbp, rsp
	push rbx
	push r13

	lea rdi, [rel confirmation_msg]
	mov rsi, 320
	lea rdx, [rel msg_format_success]
	lea rcx, [rel game_name]
	xor eax, eax
	call snprintf

	mov rdi, [rel main_window]
	mov esi, 1
	xor edx, edx
	mov ecx, 1
	lea r8, [rel fmt_plain]
	lea r9, [rel confirmation_msg]
	xor eax, eax
	call gtk_message_dialog_new
	mov rbx, rax

	lea rdi, [rel icon_replace_buf]
	mov rsi, 128
	lea rdx, [rel icon_replace]
	mov rcx, [rel appid_ptr]
	xor eax, eax
	call snprintf

	lea rdi, [rel icon_replace_buf]
	mov esi, 6 ; SIZE DIALOG 48x48
	call gtk_image_new_from_icon_name
	mov r13, rax

	mov rdi, rbx
	mov rsi, r13
	call gtk_message_dialog_set_image
	
	mov rdi, r13
	call gtk_widget_show

	mov rdi, rbx
	call gtk_dialog_run

	mov rdi, rbx
	call gtk_widget_destroy
	
	pop r13
	pop rbx
	pop rbp
	ret

apply_css:
	push rbp
	mov rbp, rsp
	push r12
	push rbx

	call gtk_css_provider_new
	mov rbx, rax ; RBX = GtkCssProvider pointer

	; load css from memory
	mov rdi, rbx
	lea rsi, [rel css_style]
	mov rdx, -1 ; lenght = -1 (to read until null byte)
	xor ecx, ecx ; error = NULL
	call gtk_css_provider_load_from_data

	; fetch default screen
	call gdk_screen_get_default ; now RAX = GdkScreen pointer

	; apply provider to screen
	mov rdi, rax ; screen
	mov rsi, rbx ; provider
	mov edx, 800 ; priority (800)
	call gtk_style_context_add_provider_for_screen

	pop rbx
	pop r12
	pop rbp
	ret
