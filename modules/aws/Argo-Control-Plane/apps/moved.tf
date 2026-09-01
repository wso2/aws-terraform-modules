moved {
  from = kubernetes_namespace_v1.this
  to   = kubernetes_namespace_v1.namespace
}

moved {
  from = kubernetes_manifest.this
  to   = kubernetes_manifest.kubernetes_object
}
