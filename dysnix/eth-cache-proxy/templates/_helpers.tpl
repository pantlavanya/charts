{{/* vim: set filetype=mustache: */}}

{{/*
Return Redis&trade; password
*/}}
{{- define "eth-cache-proxy.redisPassword" -}}
  {{- if .Values.redis.enabled -}}
    {{- include "redis.password" (dict "Values" .Values.redis) -}}
  {{- end -}}
{{- end -}}

{{- define "eth-cache-proxy.redisWriteHost" -}}
{{- if and .Values.redis.enabled (empty .Values.redis.writeAddrs) -}}
  {{- printf "%s-redis-master:6379" (include "common.names.dependency.fullname" (dict "chartName" "redis" "chartValues" .Values.redis "context" $)) }}
{{- else -}}
  {{- printf "%s:%d" (.Values.redis.writeAddrs | default "0.0.0.0") (.Values.redis.port | int | default 6379 ) }}
{{- end }}
{{- end }}

{{- define "eth-cache-proxy.redisReadHost" -}}
{{- if and .Values.redis.enabled (empty .Values.redis.readAddrs) -}}
  {{- printf "%s-redis-master:6379" (include "common.names.dependency.fullname" (dict "chartName" "redis" "chartValues" .Values.redis "context" $)) }}
{{- else -}}
  {{- printf "%s:%d" (.Values.redis.readAddrs | default "0.0.0.0") (.Values.redis.port | int | default 6379 ) }}
{{- end }}
{{- end }}

{{- define "eth-cache-proxy.config" -}}
  {{- $redis := eq .Values.cacheType "redis" | ternary (tpl (.Files.Get "default-redis.yaml.gotmpl") .) "{}" | fromYaml -}}
  {{- $common := tpl (.Files.Get "default-common.yaml.gotmpl") . | fromYaml -}}
  {{- get (merge .Values $common $redis) "config" | toYaml  -}}
{{- end -}}
