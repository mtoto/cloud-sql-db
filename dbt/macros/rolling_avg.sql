{% macro rolling_avg(value_col, time_col, nr_rows) %}

  AVG( {{ value_col }} ) OVER(ORDER BY {{ time_col }} 
      ROWS BETWEEN {{ nr_rows }} PRECEDING AND CURRENT ROW) AS rolling_avg

{% endmacro %}