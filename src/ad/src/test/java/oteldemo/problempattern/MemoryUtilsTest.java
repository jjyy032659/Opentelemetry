/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

package oteldemo.problempattern;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.lang.management.MemoryMXBean;
import java.lang.management.MemoryUsage;
import javax.management.ObjectName;
import org.junit.jupiter.api.Test;

/** Covers the heap-usage helper the ad service uses when a feature flag forces allocation. */
class MemoryUtilsTest {

  @Test
  void heapUsageIsUsedDividedByMax() {
    MemoryUtils utils = new MemoryUtils(new FakeMemoryBean(new MemoryUsage(0, 50, 50, 100)));

    assertEquals(0.5d, utils.getHeapUsage(), 0.0001d);
  }

  @Test
  void heapUsageIsMinusOneWhenTheJvmHasNoMaxHeap() {
    MemoryUtils utils = new MemoryUtils(new FakeMemoryBean(new MemoryUsage(0, 50, 50, -1)));

    assertEquals(-1.0d, utils.getHeapUsage(), 0.0001d);
  }

  /** A stand-in for the JVM bean so the test does not depend on the real heap. */
  private static final class FakeMemoryBean implements MemoryMXBean {
    private final MemoryUsage heap;

    private FakeMemoryBean(MemoryUsage heap) {
      this.heap = heap;
    }

    @Override
    public MemoryUsage getHeapMemoryUsage() {
      return heap;
    }

    @Override
    public MemoryUsage getNonHeapMemoryUsage() {
      return heap;
    }

    @Override
    public int getObjectPendingFinalizationCount() {
      return 0;
    }

    @Override
    public boolean isVerbose() {
      return false;
    }

    @Override
    public void setVerbose(boolean value) {}

    @Override
    public void gc() {}

    @Override
    public ObjectName getObjectName() {
      return null;
    }
  }
}
