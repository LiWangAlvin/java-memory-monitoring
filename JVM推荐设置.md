# JVM 设置推荐

如果JVM堆空间大小设置过大，可能会导致Linux系统的OOM Killer被激活，进而结束（kill）Java应用进程，在容器环境下可能会表现为频繁异常重启。本文介绍在容器环境下JVM堆参数的配置建议，以及OOM的相关常见问题。

## 通过-XX:MaxRAMPercentage限制堆大小（推荐）

- 在容器环境下，Java只能获取服务器的配置，无法感知容器内存限制。您可以通过设置`-Xmx`来限制JVM堆大小，但该方式存在以下问题：

  - 当规格大小调整后，需要重新设置堆大小参数。

  - 当参数设置不合理时，会出现应用堆大小未达到阈值但容器OOM被强制关闭的情况。

    **说明**

    应用程序出现OOM问题时，会触发Linux内核的OOM Killer机制。该机制能够监控占用过大内存，尤其是瞬间消耗大量内存的进程，然后它会强制关闭某项进程以腾出内存留给系统，避免系统立刻崩溃。

- 推荐的JVM参数设置。

  ```shell
  -XX:+UseContainerSupport -XX:InitialRAMPercentage=70.0 -XX:MaxRAMPercentage=70.0 -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:/home/admin/nas/gc-${POD_IP}-$(date '+%s').log -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/home/admin/nas/dump-${POD_IP}-$(date '+%s').hprof
  ```

- 参数说明如下。

  | **参数**                                                     | **说明**                                                     |
  | ------------------------------------------------------------ | ------------------------------------------------------------ |
  | `-XX:+UseContainerSupport`                                   | 使用容器内存。允许JVM从主机读取cgroup限制，例如可用的CPU和RAM，并进行相应的配置。当容器超过内存限制时，会抛出OOM异常，而不是强制关闭容器。 |
  | `-XX:InitialRAMPercentage`                                   | 设置JVM使用容器内存的初始百分比。建议与`-XX:MaxRAMPercentage`保持一致，推荐设置为70.0。 |
  | `-XX:MaxRAMPercentage`                                       | 设置JVM使用容器内存的最大百分比。由于存在系统组件开销，建议最大不超过75.0，推荐设置为70.0。 |
  | `-XX:+PrintGCDetails`                                        | 输出GC详细信息。                                             |
  | `-XX:+PrintGCDateStamps`                                     | 输出GC时间戳。日期形式，例如2019-12-24T21:53:59.234+0800。   |
  | `-Xloggc:/home/admin/nas/gc-${POD_IP}-$(date '+%s').log`     | GC日志文件路径，需要使用持久化磁盘。                         |
  | `-XX:+HeapDumpOnOutOfMemoryError`                            | JVM发生OOM时，自动生成Dump文件。                             |
  | `-XX:HeapDumpPath=/home/admin/nas/dump-${POD_IP}-$(date '+%s').hprof` | Dump文件路径。需保证Dump文件所在容器路径已存在，建议您将该容器路径挂载到NAS目录，以便自动创建目录以及实现日志的持久化存储。 |

  **说明**

  - 使用`-XX:+UseContainerSupport`参数需JDK 8u191+、JDK 10及以上版本。
  - JDK 11版本下日志相关的参数`-XX:+PrintGCDetails`、`-XX:+PrintGCDateStamps`、`-Xloggc:$LOG_PATH/gc.log`参数已废弃，请使用参数`-Xlog:gc:$LOG_PATH/gc.log`代替。

## 通过-Xms -Xmx限制堆大小

- 您可以通过设置`-Xms`和`-Xmx`来限制堆大小，但该方式存在以下两个问题：

  - 当规格大小调整后，需要重新设置堆大小参数。

  - 当参数设置不合理时，会出现应用堆大小未达到阈值但容器OOM被强制关闭的情况。

    **说明**

    应用程序出现OOM问题时，会触发Linux内核的OOM Killer机制。该机制能够监控占用过大内存，尤其是瞬间消耗大量内存的进程，然后它会强制关闭某项进程以腾出内存留给系统，避免系统立刻崩溃。

- 推荐的JVM参数设置。 

  ```shell
  -Xms2048m -Xmx2048m -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:/home/admin/nas/gc-${POD_IP}-$(date '+%s').log -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/home/admin/nas/dump-${POD_IP}-$(date '+%s').hprof
  ```

  参数说明如下。

  - | **参数**                                                     | **说明**                                                     |
    | ------------------------------------------------------------ | ------------------------------------------------------------ |
    | `-Xms`                                                       | 设置JVM初始内存大小。建议与`-Xmx`相同，避免每次垃圾回收完成后JVM重新分配内存。 |
    | `-Xmx`                                                       | 设置JVM最大可用内存大小。为避免容器OOM，请为系统预留足够的内存大小。 |
    | `-XX:+PrintGCDetails`                                        | 输出GC详细信息。                                             |
    | `-XX:+PrintGCDateStamps`                                     | 输出GC时间戳。日期形式，例如2019-12-24T21:53:59.234+0800。   |
    | `-Xloggc:/home/admin/nas/gc-${POD_IP}-$(date '+%s').log`     | GC日志文件路径，需要使用持久化磁盘。                         |
    | `-XX:+HeapDumpOnOutOfMemoryError`                            | JVM发生OOM时，自动生成Dump文件。                             |
    | `-XX:HeapDumpPath=/home/admin/nas/dump-${POD_IP}-$(date '+%s').hprof` | Dump文件路径。需保证Dump文件所在容器路径已存在，建议您将该容器路径挂载到NAS目录，以便自动创建目录以及实现日志的持久化存储。 |

  - 推荐的堆大小设置。

    | **内存规格大小** | 比例  | **JVM堆大小** |
    | ---------------- | ----- | ------------- |
    | 1 GB             | 58.6% | 600 MB        |
    | 2 GB             | 70%   | 1434 MB       |
    | 4 GB             | 70%   | 2867 MB       |
    | 8 GB             | 70%   | 5734 MB       |



