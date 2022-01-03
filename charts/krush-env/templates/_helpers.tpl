{{/*
Expand the name of the chart.
*/}}
{{- define "krush-env.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "krush-env.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "krush-env.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "krush-env.labels" -}}
helm.sh/chart: {{ include "krush-env.chart" . }}
{{ include "krush-env.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "krush-env.selectorLabels" -}}
app.kubernetes.io/name: {{ include "krush-env.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "krush-env.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "krush-env.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create flat name value parameters to be used as part of the Argo Application Definition
*/}}
{{- define "recurseFlattenMap" }}
{{- $map := first . -}}
{{- $label := last . -}}
{{- $sublabel := "" -}}
{{- range $key, $val := $map -}}
  {{- if $label | eq "" -}}
    {{- $sublabel = list $key | join "." -}}  
  {{- else if kindOf $map | eq "slice" -}}
    {{- $sublabel = printf "%s[%d]" $label $key -}}
  {{- else -}}
    {{- $sublabel = list $label $key | join "." -}}
  {{- end -}}
  {{- if kindOf $val | eq "slice" -}}
    {{- list $val $sublabel  | include "recurseFlattenMap" -}}
  {{- else if kindOf $val | eq "map" -}}
    {{- list $val $sublabel | include "recurseFlattenMap" -}}
  {{- else -}}
- name: {{ $sublabel | quote }}
  value: {{ $val | quote }}
{{ end -}}
{{- end -}}
{{- end }}