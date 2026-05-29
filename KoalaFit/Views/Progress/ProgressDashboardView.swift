import SwiftUI
import Charts

struct ProgressDashboardView: View {
    @State private var selectedMetric = "Weight"
    let headerMetrics = ["Weight", "Body Fat", "Measurements"]
    
    // Mock chart data
    let weightData = [
        (1, 75.0), (2, 74.5), (3, 74.0), (4, 73.8),
        (5, 73.0), (6, 73.5), (7, 72.8), (8, 72.5),
        (9, 72.2), (10, 72.0)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Progress")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.white)
                            Text("Track your body goals progress")
                                .foregroundColor(AppTheme.secondaryText)
                        }
                        .padding(.horizontal)
                        
                        // Top Static Metric Cards
                        HStack(spacing: 12) {
                            ProgressMetricCard(title: "Weight", value: "72 kg", change: "-6 kg", changeColor: .green)
                            ProgressMetricCard(title: "Body Fat", value: "18%", change: "-4%", changeColor: .green)
                            ProgressMetricCard(title: "Muscle Mass", value: "58 kg", change: "+3 kg", changeColor: .green)
                        }
                        .padding(.horizontal)
                        
                        // Chart Section
                        VStack(alignment: .leading, spacing: 16) {
                            
                            // Metric Toggle
                            HStack(spacing: 0) {
                                ForEach(headerMetrics, id: \.self) { metric in
                                    Button(action: { selectedMetric = metric }) {
                                        Text(metric)
                                            .font(.footnote)
                                            .fontWeight(.medium)
                                            .padding(.vertical, 8)
                                            .frame(maxWidth: .infinity)
                                            .background(selectedMetric == metric ? AppTheme.primary : AppTheme.surface)
                                            .foregroundColor(selectedMetric == metric ? .white : AppTheme.secondaryText)
                                    }
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                            
                            VStack(alignment: .leading) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading) {
                                        Text("Body \(selectedMetric)")
                                            .foregroundColor(.white)
                                        Text("Last 10 weeks")
                                            .font(.caption)
                                            .foregroundColor(AppTheme.secondaryText)
                                    }
                                    Spacer()
                                    Text(selectedMetric == "Weight" ? "-6 kg" : "-4%")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                }
                                
                                // iOS 16 Charts implementation
                                Chart {
                                    ForEach(weightData, id: \.0) { item in
                                        LineMark(
                                            x: .value("Week", "W\(item.0)"),
                                            y: .value("Weight", item.1)
                                        )
                                        .interpolationMethod(.catmullRom)
                                        .foregroundStyle(AppTheme.primary)
                                        
                                        PointMark(
                                            x: .value("Week", "W\(item.0)"),
                                            y: .value("Weight", item.1)
                                        )
                                        .foregroundStyle(AppTheme.primary)
                                    }
                                }
                                .chartYScale(domain: 71...78)
                                .frame(height: 200)
                                .padding(.top)
                            }
                            .padding()
                            .background(AppTheme.surface)
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                        
                        // Progress Photos
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Progress Photos")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white)
                                Spacer()
                                Button(action: {}) {
                                    Label("Add", systemImage: "camera")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(AppTheme.primary)
                                }
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    EmptyPhotoCard()
                                    EmptyPhotoCard()
                                    EmptyPhotoCard()
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        Spacer().frame(height: 100)
                    }
                    .padding(.top)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct ProgressMetricCard: View {
    let title: String
    let value: String
    let change: String
    let changeColor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(AppTheme.secondaryText)
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
            Text(change)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(changeColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppTheme.surface)
        .cornerRadius(16)
    }
}

struct EmptyPhotoCard: View {
    var body: some View {
        VStack {
            Image(systemName: "calendar")
                .foregroundColor(AppTheme.secondaryText)
                .font(.title2)
            Text("Photo")
                .font(.caption)
                .foregroundColor(AppTheme.secondaryText)
                .padding(.top, 4)
        }
        .frame(width: 100, height: 140)
        .background(AppTheme.surface)
        .cornerRadius(16)
    }
}

struct ProgressDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressDashboardView()
    }
}
