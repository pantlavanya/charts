{{/*
This template serves as the blueprint for the Deployment objects that are created
within the base library.
*/}}
{{- define "base.deployment" }}
---
apiVersion: {{ include "common.capabilities.deployment.apiVersion" . }}
kind: Deployment
metadata:
  name: {{ include "common.names.fullname" . }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  {{- if .Values.updateStrategy }}
  strategy: {{- tpl (toYaml .Values.updateStrategy) $ | nindent 4 }}
  {{- end }}
  selector:
    matchLabels: {{- include "common.labels.matchLabels" . | nindent 6 }}
  template:
    metadata:
      {{- if or .Values.checksums .Values.podAnnotations }}
      annotations:
        {{- range .Values.checksums }}
        checksum/{{ . | trimPrefix "/" }}: {{ include (print $.Template.BasePath "/" (. | trimPrefix "/")) $ | sha256sum }}
        {{- end }}
        {{- if .Values.podAnnotations }}
        {{- include "common.tplvalues.render" (dict "value" .Values.podAnnotations "context" $) | nindent 8 }}
        {{- end }}
      {{- end }}
      labels: {{- include "common.labels.standard" . | nindent 8 }}
        {{- if .Values.podLabels }}
        {{- include "common.tplvalues.render" (dict "value" .Values.podLabels "context" $) | nindent 8 }}
        {{- end }}
    spec:
      serviceAccountName: {{ include "base.serviceAccountName" . }}
      {{- include "base.imagePullSecrets" . | nindent 6 }}
      dnsPolicy: {{ .Values.dnsPolicy }}
      {{- if .Values.priorityClassName }}
      priorityClassName: {{ .Values.priorityClassName | quote }}
      {{- end }}
      {{- if .Values.hostAliases }}
      hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.hostAliases "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.affinity }}
      affinity: {{- include "common.tplvalues.render" (dict "value" .Values.affinity "context" $) | nindent 8 }}
      {{- else }}
      affinity:
        podAffinity: {{- include "common.affinities.pods" (dict "type" .Values.podAffinityPreset "context" $) | nindent 10 }}
        podAntiAffinity: {{- include "common.affinities.pods" (dict "type" .Values.podAntiAffinityPreset "context" $) | nindent 10 }}
        nodeAffinity: {{- include "common.affinities.nodes" (dict "type" .Values.nodeAffinityPreset.type "key" .Values.nodeAffinityPreset.key "values" .Values.nodeAffinityPreset.values) | nindent 10 }}
      {{- end }}
      {{- if .Values.nodeSelector }}
      nodeSelector: {{- include "common.tplvalues.render" (dict "value" .Values.nodeSelector "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.tolerations }}
      tolerations: {{- include "common.tplvalues.render" (dict "value" .Values.tolerations "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.schedulerName }}
      schedulerName: {{ .Values.schedulerName | quote }}
      {{- end }}
      {{- if .Values.podSecurityContext.enabled }}
      securityContext: {{- omit .Values.podSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.initContainers }}
      initContainers: {{- include "common.tplvalues.render" (dict "value" .Values.initContainers "context" $) | nindent 10 }}
      {{- end }}
      containers:
        - name: app
          image: {{ include "base.image" . }}
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          {{- if .Values.containerSecurityContext.enabled }}
          securityContext: {{- omit .Values.containerSecurityContext "enabled" | toYaml | nindent 12 }}
          {{- end }}
          {{- if .Values.command }}
          command: {{- include "common.tplvalues.render" (dict "value" .Values.command "context" $) | nindent 12 }}
          {{- end }}
          {{- if .Values.args }}
          args: {{- include "common.tplvalues.render" (dict "value" .Values.args "context" $) | nindent 12 }}
          {{- end }}
          {{- if .Values.env }}
          env:
          {{- include "common.tplvalues.render" (dict "value" .Values.env "context" $) | nindent 12 }}
          {{- end }}
          {{- if .Values.envFrom }}
          envFrom: {{- include "common.tplvalues.render" (dict "value" .Values.envFrom "context" $) | nindent 12 }}
          {{- end }}
          {{- if .Values.containerPorts }}
          ports: {{- (include "base.deployment.containerPorts" .) | nindent 12 }}
          {{- end }}
          resources: {{- include "common.tplvalues.render" (dict "value" .Values.resources "context" $) | nindent 12 }}
          {{- if .Values.livenessProbe.enabled }}
          livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.livenessProbe "enabled") "context" $) | nindent 12 }}
          {{- end }}
          {{- if .Values.readinessProbe.enabled }}
          readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.readinessProbe "enabled") "context" $) | nindent 12 }}
          {{- end }}
          volumeMounts:
            {{- if .Values.persistence.enabled }}
            - name: data
              mountPath: {{ .Values.persistence.mountPath }}
            {{- end }}
            {{- if .Values.volumeMounts }}
            {{- include "common.tplvalues.render" (dict "value" .Values.volumeMounts "context" $) | nindent 12 }}
            {{- end }}
      volumes:
        {{- if .Values.persistence.enabled }}
        - name: data
          persistentVolumeClaim:
            claimName: {{ include "base.pvc" . }}
        {{- end }}
        {{- if .Values.volumes }}
        {{- include "common.tplvalues.render" (dict "value" .Values.volumes "context" $) | nindent 8 }}
        {{- end }}
{{- end }}
