"""Metrics extraction and result comparison utilities."""
import os
import yaml


def extract_all_metrics(results_dict):
    """Extract all metrics from results dictionary.
    
    Flattens nested metrics from both results_dict and trainer_metrics sections
    into a single dictionary for easy comparison.
    
    Args:
        results_dict: Dictionary containing training results
        
    Returns:
        Dictionary with flattened metrics as {metric_name: value}
    """
    metrics = {}
    
    # Extract from results_dict section (final epoch metrics)
    if "results_dict" in results_dict and isinstance(results_dict["results_dict"], dict):
        for key, value in results_dict["results_dict"].items():
            if isinstance(value, (int, float)):
                metrics[f"results_dict/{key}"] = float(value)
    
    # Extract from trainer_metrics section (additional trainer statistics)
    if "trainer_metrics" in results_dict and isinstance(results_dict["trainer_metrics"], dict):
        for key, value in results_dict["trainer_metrics"].items():
            if isinstance(value, (int, float)):
                metrics[f"trainer_metrics/{key}"] = float(value)
    
    return metrics


def should_save_results(save_dir, new_results_dict):
    """Check if new results are better than saved results by comparing all metrics.
    
    Strategy: Save results if more metrics improved than worsened.
    This prevents overwriting good models with marginally worse ones.
    
    Args:
        save_dir: Directory where previous results.yaml is stored
        new_results_dict: New results dictionary from current training
        
    Returns:
        Tuple of (should_save: bool, message: str)
    """
    results_file = os.path.join(save_dir, "results.yaml")
    
    # If no previous results exist, save the new ones (first run)
    if not os.path.exists(results_file):
        return True, "No previous results found"
    
    try:
        with open(results_file, "r") as f:
            old_results_dict = yaml.safe_load(f)
        
        old_metrics = extract_all_metrics(old_results_dict)
        new_metrics = extract_all_metrics(new_results_dict)
        
        if not old_metrics or not new_metrics:
            return True, "Could not extract metrics for comparison"
        
        # Compare metrics: count improvements, regressions, and unchanged values
        better_count = 0
        worse_count = 0
        equal_count = 0
        improvement_details = []
        
        # Check common metrics between old and new
        for metric_name in old_metrics:
            if metric_name in new_metrics:
                old_val = old_metrics[metric_name]
                new_val = new_metrics[metric_name]
                
                if new_val > old_val:
                    better_count += 1
                    improvement_details.append(f"  ✓ {metric_name}: {old_val:.4f} → {new_val:.4f}")
                elif new_val < old_val:
                    worse_count += 1
                    improvement_details.append(f"  ✗ {metric_name}: {old_val:.4f} → {new_val:.4f}")
                else:
                    equal_count += 1
        
        # Metrics in new results but not in old (new metrics discovered)
        for metric_name in new_metrics:
            if metric_name not in old_metrics:
                improvement_details.append(f"  + {metric_name}: N/A → {new_metrics[metric_name]:.4f}")
        
        # Decision: save if more metrics improved than worsened
        should_save = better_count >= worse_count
        
        summary = f"Metrics: {better_count} improved, {worse_count} worsened, {equal_count} unchanged\n"
        for detail in improvement_details[:10]:  # Show first 10 metrics for readability
            summary += detail + "\n"
        if len(improvement_details) > 10:
            summary += f"  ... and {len(improvement_details) - 10} more metrics"
        
        return should_save, summary
    
    except Exception as e:
        return True, f"Error comparing results, saving anyway: {str(e)}"
