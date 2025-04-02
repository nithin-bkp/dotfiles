## Setting UP and Shutting Down

To setup tracing all that is needed is toggle on few of the required `envs`

```env
OTEL_SDK_DISABLED=true
OTEL_EXPORTER_ENDPOINT=http://localhost:4317
OTEL_TRACING_INSTRUMENTORS=django,requests,aiorequests,postgres,clickhouse,redis,kafka,celery
OTEL_TRACING_EXPORTERS=console,otlp
OTEL_METRICS_INSTRUMENTORS=system.cpu,process
OTEL_METRICS_EXPORTERS=console,otlp
```

```json
SYSTEM_METRICS: dict[str, list[str] | None] = {
    "system.cpu.time": ["idle", "user", "system", "irq"],
    "system.cpu.utilization": ["idle", "user", "system", "irq"],
    "system.memory.usage": ["used", "free", "cached"],
    "system.memory.utilization": ["used", "free", "cached"],
    "system.swap.usage": ["used", "free"],
    "system.swap.utilization": ["used", "free"],
    "system.disk.io": ["read", "write"],
    "system.disk.operations": ["read", "write"],
    "system.disk.time": ["read", "write"],
    "system.network.dropped.packets": ["transmit", "receive"],
    "system.network.packets": ["transmit", "receive"],
    "system.network.errors": ["transmit", "receive"],
    "system.network.io": ["transmit", "receive"],
    "system.network.connections": ["family", "type"],
    "system.thread_count": None,
    "process.runtime.memory": ["rss", "vms"],
    "process.runtime.cpu.time": ["user", "system"],
    "process.runtime.gc_count": None,
    "process.runtime.thread_count": None,
    "process.runtime.cpu.utilization": None,
    "process.runtime.context_switches": ["involuntary", "voluntary"],
    "process.open_file_descriptor.count": None,
}
```

**Notes**: 
1. setting `OTEL_SDK_DISABLED=true` disables emitting/generating traces data 
2. If `OTEL_TRACING_EXPORTERS` is empty or not set, the `instrumentors` are skipped and the tracing setup is skipped, which mean `NoOp` Tracer will be used by the `SDK` which does nothing. The same is the case with `OTEL_METRICS_EXPORTERS`. `OTEL_EXPORTER_ENDPOINT` is used  when `otlp` is configured as one of the exporters.
3. If `OTEL_TRACING_INSTRUMENTORS` is empty or not set, all available `instrumentors` + `clickhouse` are used by the default. But for `OTEL_METRICS_INSTRUMENTORS` if no values are set instrumentation is disabled.
4. It is enough to only partially provide the keys up to `.` from the `SYSTEM_METRICS` dictionary as `OTEL_METRICS_INSTRUMENTORS` . All the `instrumentors` whose key prefix-match the provide values will used.  