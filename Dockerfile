FROM supabase/gotrue:latest

COPY templates/email/magic_link.html /etc/gotrue/templates/magic_link.html
COPY templates/email/recovery.html /etc/gotrue/templates/recovery.html
