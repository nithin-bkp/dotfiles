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


## `Clickhouse` Tables

### Raw `ReplicatedMergeTree` Table

```sql
CREATE TABLE vusmart.__internal_api_raw_spans_data ON CLUSTER vusmart
(
    `Timestamp` DateTime64(9) CODEC(Delta(8), ZSTD(1)),
    `TraceId` String CODEC(ZSTD(1)),
    `SpanId` String CODEC(ZSTD(1)),
    `ParentSpanId` String CODEC(ZSTD(1)),
    `TraceState` String CODEC(ZSTD(1)),
    `SpanName` LowCardinality(String) CODEC(ZSTD(1)),
    `SpanKind` LowCardinality(String) CODEC(ZSTD(1)),
    `ServiceName` LowCardinality(String) CODEC(ZSTD(1)),
    `ResourceAttributes` Map(LowCardinality(String), String) CODEC(ZSTD(1)),
    `ScopeName` String CODEC(ZSTD(1)),
    `ScopeVersion` String CODEC(ZSTD(1)),
    `SpanAttributes` Map(LowCardinality(String), String) CODEC(ZSTD(1)),
    `Duration` UInt64 CODEC(ZSTD(1)),
    `StatusCode` LowCardinality(String) CODEC(ZSTD(1)),
    `StatusMessage` String CODEC(ZSTD(1)),
    `Events.Timestamp` Array(DateTime64(9)) CODEC(ZSTD(1)),
    `Events.Name` Array(LowCardinality(String)) CODEC(ZSTD(1)),
    `Events.Attributes` Array(Map(LowCardinality(String), String)) CODEC(ZSTD(1)),
    `Links.TraceId` Array(String) CODEC(ZSTD(1)),
    `Links.SpanId` Array(String) CODEC(ZSTD(1)),
    `Links.TraceState` Array(String) CODEC(ZSTD(1)),
    `Links.Attributes` Array(Map(LowCardinality(String), String)) CODEC(ZSTD(1)),
    INDEX idx_trace_id TraceId TYPE bloom_filter(0.001) GRANULARITY 1,
    INDEX idx_duration Duration TYPE minmax GRANULARITY 1
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{uuid}/{shard}', '{replica}')
PARTITION BY toDate(Timestamp)
ORDER BY (ServiceName, SpanName, toDateTime(Timestamp))
SETTINGS index_granularity = 8192, ttl_only_drop_parts = 1;
```

### Raw `Distributed`

```sql
CREATE TABLE vusmart.__internal_api_raw_spans ON CLUSTER vusmart
AS vusmart.__internal_api_raw_spans_data
ENGINE = Distributed('vusmart', 'vusmart', '__internal_api_raw_spans_data', rand());
```



### Replicated `vusmart.__internal_api_span_data`

```sql
CREATE TABLE vusmart.__internal_api_spans_data ON CLUSTER vusmart
(
    `Timestamp` DateTime64(9) CODEC(Delta(8), ZSTD(1)),
    `TraceId` String CODEC(ZSTD(1)),
    `SpanId` String CODEC(ZSTD(1)),
    `ParentSpanId` String CODEC(ZSTD(1)),
    `TraceState` String CODEC(ZSTD(1)),
    `SpanName` LowCardinality(String) CODEC(ZSTD(1)),
    `SpanKind` LowCardinality(String) CODEC(ZSTD(1)),
    `ServiceName` LowCardinality(String) CODEC(ZSTD(1)),
    `ResourceAttributes` Map(LowCardinality(String), String) CODEC(ZSTD(1)),
    `ScopeName` String CODEC(ZSTD(1)),
    `ScopeVersion` String CODEC(ZSTD(1)),
    `SpanAttributes` Map(LowCardinality(String), String) CODEC(ZSTD(1)),
    `Duration` UInt64 CODEC(ZSTD(1)),
    `StatusCode` LowCardinality(String) CODEC(ZSTD(1)),
    `StatusMessage` String CODEC(ZSTD(1)),
    `Events.Timestamp` Array(DateTime64(9)) CODEC(ZSTD(1)),
    `Events.Name` Array(LowCardinality(String)) CODEC(ZSTD(1)),
    `Events.Attributes` Array(Map(LowCardinality(String), String)) CODEC(ZSTD(1)),
    `Links.TraceId` Array(String) CODEC(ZSTD(1)),
    `Links.SpanId` Array(String) CODEC(ZSTD(1)),
    `Links.TraceState` Array(String) CODEC(ZSTD(1)),
    `Links.Attributes` Array(Map(LowCardinality(String), String)) CODEC(ZSTD(1)),
    `http_flavor` String,
    `http_host` LowCardinality(String),
    `http_method` LowCardinality(String),
    `http_route` String,
    `http_scheme` String,
    `http_server_name` String,
    `http_status_code` LowCardinality(String),
    `http_target` String,
    `http_url` String,
    `http_user_agent` String,
    `net_host_port` String,
    `net_peer_ip` String,
    `net_peer_port` String,
    `net_peer_name` String,
    `net_transport` String,
    `db_system` LowCardinality(String),
    `db_name` LowCardinality(String),
    `db_statement` String,
    `db_user` String,
    `db_redis_database_index` String,
    `db_redis_args_length` String,
    `messaging_destination` LowCardinality(String),
    `messaging_destination_kind` String,
    `messaging_operation` String,
    `messaging_system` LowCardinality(String),
    `application_name` LowCardinality(String),
    INDEX idx_trace_id TraceId TYPE bloom_filter(0.001) GRANULARITY 1,
    INDEX idx_duration Duration TYPE minmax GRANULARITY 1
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{uuid}/{shard}', '{replica}')
PARTITION BY toDate(Timestamp)
ORDER BY (ServiceName, SpanName, toDateTime(Timestamp))
SETTINGS index_granularity = 8192, ttl_only_drop_parts = 1;
```

### Distributed `__internal_apm_span`
```sql
CREATE TABLE vusmart.__internal_api_spans ON CLUSTER vusmart
AS vusmart.__internal_api_spans_data
ENGINE = Distributed('vusmart', 'vusmart', '__internal_apm_spans_data', rand());
```

### `MV` for `Replicated` to  `Distributed` 

```sql
CREATE MATERIALIZED VIEW vusmart.__internal_api_spans_mv ON CLUSTER vusmart
TO vusmart.__internal_api_spans
AS
SELECT
    Timestamp,
    TraceId,
    SpanId,
    ParentSpanId,
    TraceState,
    SpanName,
    SpanKind,
    ServiceName,
    ResourceAttributes,
    ScopeName,
    ScopeVersion,
    SpanAttributes,
    Duration,
    StatusCode,
    StatusMessage,
    Events.Timestamp AS Events_Timestamp,
    Events.Name AS Events_Name,
    Events.Attributes AS Events_Attributes,
    SpanAttributes['http.flavor'] AS http_flavor,
    SpanAttributes['http.host'] AS http_host,
    SpanAttributes['http.method'] AS http_method,
    SpanAttributes['http.route'] AS http_route,
    SpanAttributes['http.scheme'] AS http_scheme,
    SpanAttributes['http.server_name'] AS http_server_name,
    SpanAttributes['http.status_code'] AS http_status_code,
    SpanAttributes['http.target'] AS http_target,
    SpanAttributes['http.url'] AS http_url,
    SpanAttributes['http.user_agent'] AS http_user_agent,
    SpanAttributes['net.host.port'] AS net_host_port,
    SpanAttributes['net.peer.ip'] AS net_peer_ip,
    SpanAttributes['net.peer.port'] AS net_peer_port,
    SpanAttributes['net.peer.name'] AS net_peer_name,
    SpanAttributes['net.transport'] AS net_transport,
    SpanAttributes['db.system'] AS db_system,
    SpanAttributes['db.name'] AS db_name,
    SpanAttributes['db.statement'] AS db_statement,
    SpanAttributes['db.user'] AS db_user,
    SpanAttributes['db.redis.database_index'] AS db_redis_database_index,
    SpanAttributes['db.redis.args_length'] AS db_redis_args_length,
    SpanAttributes['messaging.destination'] AS messaging_destination,
    SpanAttributes['messaging.destination_kind'] AS messaging_destination_kind,
    SpanAttributes['messaging.operation'] AS messaging_operation,
    SpanAttributes['messaging.system'] AS messaging_system,
    ServiceName AS application_name
FROM vusmart.__internal_api_raw_spans;
```