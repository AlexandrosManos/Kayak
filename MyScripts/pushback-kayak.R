#!/usr/bin/env Rscript
#
# Copyright (c) 2019 University of Utah
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR(S) DISCLAIM ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL AUTHORS BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

source('scripts/common.R')

# Read samples from a file into a dataframe.
#
# \param filename: File containing samples obtained by running pushback-kayak.
#
# \return A dataframe containing samples, with the header intact.
readSamples <- function(filename) {
    read.table(filename, header=TRUE)
}

# Plot the Median and 99th latency vs throughput for the PUSHBACK-KAYAK workload,
# faceted by slo value, with order and order2 values shown as labels.
#
# \param d: Samples (with header) from a pushback-kayak run.
plotLatencyVsThroughput <- function(d) {
    # Create a label combining order and order2 for each data point.
    d$combo <- paste0("order=", d$Order, ", order2=", d$Order2)

    # Create a label for slo.
    d$slo_label <- paste0("SLO=", d$Slo)

    # Melt the dataframe so median (50) and tail (99) latency are in one column.
    d_melt <- melt(d,
                   id.vars = c("Offered", "Slo", "slo_label", "Order", "Order2", "combo"),
                   measure.vars = c("X50", "X99"),
                   variable.name = "Percentile",
                   value.name = "Latency_ns")

    # Rename percentile labels for clarity.
    d_melt$Percentile <- ifelse(d_melt$Percentile == "X50", "Median (50th)", "Tail (99th)")

    # Plot: x = Throughput, y = Latency, colour = order/order2 combo,
    #       linetype = percentile, facet = slo value.
    p <- ggplot(d_melt, aes(x = Offered, y = Latency_ns / 1000,
                            col = combo, linetype = Percentile)) +
            geom_line() +
            geom_point() +
            facet_wrap(~ slo_label) +
            scale_x_continuous(name = 'Throughput (Million Operations per sec)',
                    labels = function(x) x / 1e6) +
            scale_y_continuous(name = expression(paste('Latency (', mu, 's)'))) +
            scale_color_brewer(palette = 'Set1',
                    name = 'Order / Order2') +
            scale_linetype_discrete(name = 'Percentile') +
            myTheme +
            theme(legend.position = 'bottom',
                  legend.box = 'vertical')

    # Save the plot to a file.
    ggsave(plot = p, filename = 'pushback_kayak_latency_vs_thrpt.pdf',
           width = 10, height = 4, units = 'in')
    message("Saved pushback_kayak_latency_vs_thrpt.pdf")
}

# Plot the throughput for each (slo, order, order2) combination.
#
# \param d: Samples (with header) from a pushback-kayak run.
plotThroughput <- function(d) {
    d$combo <- paste0("order=", d$Order, ", order2=", d$Order2)
    d$slo_label <- paste0("SLO=", d$Slo)

    p <- ggplot(d, aes(x = combo, y = Thrpt / 1e6, fill = slo_label)) +
            geom_bar(stat = 'identity', position = 'dodge') +
            scale_y_continuous(name = 'Throughput (Million Operations per sec)') +
            scale_x_discrete(name = 'Order / Order2 Combination') +
            scale_fill_brewer(palette = 'Set1', name = 'SLO') +
            myTheme +
            theme(axis.text.x = element_text(angle = 20, hjust = 1),
                  legend.position = 'bottom')

    ggsave(plot = p, filename = 'pushback_kayak_throughput.pdf',
           width = 8, height = 4, units = 'in')
    message("Saved pushback_kayak_throughput.pdf")
}

# Plots all PUSHBACK-KAYAK graphs:
#  - Latency (50th and 99th percentile) vs Throughput, faceted by SLO
#  - Throughput per (slo, order, order2) combination
plotAllFigs <- function(invoke = "true") {
    filename <- paste0("pushback_kayak_invoke_", invoke, ".data")
    d <- readSamples(filename)
    plotLatencyVsThroughput(d)
    plotThroughput(d)
}
