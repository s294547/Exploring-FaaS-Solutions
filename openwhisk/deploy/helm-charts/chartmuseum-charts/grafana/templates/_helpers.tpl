{{- define "grafana.app.labels" -}}
app: grafana
app.kubernetes.io/name: {{ nospace .Chart.Name | kebabcase }}
app.kubernetes.io/version: {{ .Chart.Version | quote }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "grafana.gomaxprocs" -}}
- name: GOMAXPROCS

{{- $cpu := .Values.opt.resources.limits.cpu }}
{{- if contains "m" $cpu }}
{{- $cpu = ($cpu | replace "m" "") }}
{{- else }}
{{- $cpu = (float64 $cpu | mul 1000) }}
{{- end }}

  value: {{ 1000 | div $cpu | add1 | quote }}
{{- end -}}