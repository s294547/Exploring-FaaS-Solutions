{{- define "app.labels" -}}
app: loki
app.kubernetes.io/name: {{ nospace .Chart.Name | kebabcase }}
app.kubernetes.io/version: {{ .Chart.Version | quote }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "gomaxprocs" -}}
- name: GOMAXPROCS

{{- $cpu := (toString .resources.limits.cpu) }}
{{- if contains "m" $cpu }}
{{- $cpu = ($cpu | replace "m" "") }}
{{- $cpu = (1001 | div $cpu | add1) }}
{{- end }}

  value: {{ $cpu | quote }}
{{- end -}}
