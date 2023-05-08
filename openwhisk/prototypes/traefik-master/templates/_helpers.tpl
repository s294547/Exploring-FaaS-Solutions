{{- define "app.labels" -}}
app: traefik
app.kubernetes.io/name: {{ nospace .Chart.Name | kebabcase }}
app.kubernetes.io/version: {{ .Chart.Version | quote }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
