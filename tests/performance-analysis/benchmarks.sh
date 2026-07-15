#!/usr/bin/env bash
set -euo pipefail

echo "################################################################################"
echo "Harvester cluster performance benchmark"
echo "Node: $(hostname)"
echo "Date: $(date)"
echo "################################################################################"
echo ""

# STORAGE - BASE WRITE TEST (dd)
echo "### [STORAGE] Sequential write test (dd)"
echo "command: dd if=/dev/zero of=/usr/local/testfile1 bs=1G count=2 oflag=direct"

dd if=/dev/zero of=/usr/local/testfile1 bs=1G count=2 oflag=direct

echo ""
rm -f /usr/local/testfile1
echo ""

# STORAGE - SEQUENTIAL WRITE / READ (single stream)
echo "### [STORAGE] Sequential write (fio single stream)"
echo "command: fio --name=seq-write --ioengine=libaio --rw=write --bs=1M --filename=/usr/local/testfile1 --size=5GB --direct=1 --iodepth=128 --group_reporting"

fio --name=seq-write \
  --ioengine=libaio \
  --rw=write \
  --bs=1M \
  --filename=/usr/local/testfile1 \
  --size=5GB \
  --direct=1 \
  --iodepth=128 \
  --group_reporting

echo ""

echo "### [STORAGE] Sequential read (fio single stream)"
echo "command: fio --name=seq-read --ioengine=libaio --rw=read --bs=1M --filename=/usr/local/testfile2 --size=5GB --direct=1 --iodepth=128 --group_reporting"

fio --name=seq-read \
  --ioengine=libaio \
  --rw=read \
  --bs=1M \
  --filename=/usr/local/testfile2 \
  --size=5GB \
  --direct=1 \
  --iodepth=128 \
  --group_reporting

echo ""
rm -f /usr/local/testfile1 /usr/local/testfile2
echo ""

# STORAGE - SEQUENTIAL MULTIJOB
echo "### [STORAGE] Sequential write (fio multi-job)"
echo "command: fio --name=seq-write-multi --ioengine=libaio --rw=write --bs=1M --filename=/usr/local/testfile1 --size=5GB --direct=1 --numjobs=4 --iodepth=32 --group_reporting"

fio --name=seq-write-multi \
  --ioengine=libaio \
  --rw=write \
  --bs=1M \
  --filename=/usr/local/testfile1 \
  --size=5GB \
  --direct=1 \
  --numjobs=4 \
  --iodepth=32 \
  --group_reporting

echo ""

echo "### [STORAGE] Sequential read (fio multi-job)"
echo "command: fio --name=seq-read-multi --ioengine=libaio --rw=read --bs=1M --filename=/usr/local/testfile2 --size=5GB --direct=1 --numjobs=4 --iodepth=32 --group_reporting"

fio --name=seq-read-multi \
  --ioengine=libaio \
  --rw=read \
  --bs=1M \
  --filename=/usr/local/testfile2 \
  --size=5GB \
  --direct=1 \
  --numjobs=4 \
  --iodepth=32 \
  --group_reporting

echo ""
rm -f /usr/local/testfile1 /usr/local/testfile2
echo ""

# STORAGE - RANDOM I/O
echo "### [STORAGE] Random write (fio 4k)"
echo "command: fio --name=rand-write --ioengine=libaio --rw=randwrite --bs=4k --filename=/usr/local/testfile1 --size=5GB --direct=1 --numjobs=4 --iodepth=32 --group_reporting"

fio --name=rand-write \
  --ioengine=libaio \
  --rw=randwrite \
  --bs=4k \
  --filename=/usr/local/testfile1 \
  --size=5GB \
  --direct=1 \
  --numjobs=4 \
  --iodepth=32 \
  --group_reporting

echo ""

echo "### [STORAGE] Random read (fio 4k)"
echo "command: fio --name=rand-read --ioengine=libaio --rw=randread --bs=4k --filename=/usr/local/testfile2 --size=5GB --direct=1 --numjobs=4 --iodepth=32 --group_reporting"

fio --name=rand-read \
  --ioengine=libaio \
  --rw=randread \
  --bs=4k \
  --filename=/usr/local/testfile2 \
  --size=5GB \
  --direct=1 \
  --numjobs=4 \
  --iodepth=32 \
  --group_reporting

echo ""
rm -f /usr/local/testfile1 /usr/local/testfile2
echo ""

# CPU SCHEDULING / SYSTEM METRICS
echo "### [CPU] mpstat per CPU"
echo "command: mpstat -P ALL 1 10"

mpstat -P ALL 1 10

echo ""

# IO / SYSTEM LOAD
echo "### [SYSTEM] iostat extended"
echo "command: iostat -x 1 10"

iostat -x 1 10

echo ""

echo "### [SYSTEM] memory usage"
echo "command: free -m"

free -m

echo ""

echo "### [SYSTEM] vmstat"
echo "command: vmstat 1 10"

vmstat 1 10

echo ""

# END
echo "################################################################################"
echo "Benchmark completed"
echo "################################################################################"
