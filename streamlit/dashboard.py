import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go

# ==============================================================================
# 1. SETUP & CONFIG
# ==============================================================================
st.set_page_config(page_title="Netball Match Dashboard", layout="wide", page_icon="🏐")

st.markdown("""
<style>
    .stMetric {background-color: #f0f2f6; padding: 10px; border-radius: 5px;}
    .css-1d391kg {padding-top: 1rem;} 
</style>
""", unsafe_allow_html=True)

# ==============================================================================
# 2. GLOBAL DEFINITIONS (Court Maps)
# ==============================================================================

# CPA Phase 1 Map
map_phase1 = pd.DataFrame([
    {"Location": "Center Left Attack", "x": 1, "y": 2, "Label": "C Left (A)"},
    {"Location": "Center Mid Attack", "x": 2, "y": 2, "Label": "C Mid (A)"},
    {"Location": "Center Right Attack", "x": 3, "y": 2, "Label": "C Right (A)"},
    {"Location": "Center Left Defense", "x": 1, "y": 1, "Label": "C Left (D)"},
    {"Location": "Center Mid Defense", "x": 2, "y": 1, "Label": "C Mid (D)"},
    {"Location": "Center Right Defense", "x": 3, "y": 1, "Label": "C Right (D)"}
])

# CPA Phase 2 Map
map_phase2 = pd.DataFrame([
    {"Location": "Center Left Attack", "x": 1, "y": 2, "Label": "C Left (A)"},
    {"Location": "Center Mid Attack", "x": 2, "y": 2, "Label": "C Mid (A)"},
    {"Location": "Center Right Attack", "x": 3, "y": 2, "Label": "C Right (A)"},
    {"Location": "Center Left Defense", "x": 1, "y": 1, "Label": "C Left (D)"},
    {"Location": "Center Mid Defense", "x": 2, "y": 1, "Label": "C Mid (D)"},
    {"Location": "Center Right Defense", "x": 3, "y": 1, "Label": "C Right (D)"},
    {"Location": "Attacking Left", "x": 1, "y": 3, "Label": "Att Left"},
    {"Location": "Attacking Middle", "x": 2, "y": 3, "Label": "Att Mid"},
    {"Location": "Attacking Right", "x": 3, "y": 3, "Label": "Att Right"},
    {"Location": "Attacking Left Pocket", "x": 1, "y": 4, "Label": "AL Pocket"},
    {"Location": "Attacking D", "x": 2, "y": 4, "Label": "Att Circle"},
    {"Location": "Attacking Right Pocket", "x": 3, "y": 4, "Label": "AR Pocket"}
])

# Physical Coords for Pass Flow
zone_coords = pd.DataFrame([
    {"zone_name": "Center Left Defense", "x": 20, "y": 85},
    {"zone_name": "Center Mid Defense", "x": 50, "y": 85},
    {"zone_name": "Center Right Defense", "x": 80, "y": 85},
    {"zone_name": "Center Left Attack", "x": 20, "y": 115},
    {"zone_name": "Center Mid Attack", "x": 50, "y": 115},
    {"zone_name": "Center Right Attack", "x": 80, "y": 115},
    {"zone_name": "Attacking Left", "x": 15, "y": 160},
    {"zone_name": "Attacking Middle", "x": 50, "y": 160},
    {"zone_name": "Attacking Right", "x": 85, "y": 160},
    {"zone_name": "Attacking Left Pocket", "x": 10, "y": 185},
    {"zone_name": "Attacking Right Pocket", "x": 90, "y": 185},
    {"zone_name": "Attacking D", "x": 50, "y": 180}
])

# Defense Map (GN/TO)
court_map_gnto = pd.DataFrame([
    {"Location": "Defensive Left Pocket", "x": 1, "y": 1, "Zone_Label": "DL Pocket"},
    {"Location": "Defensive D", "x": 2, "y": 1, "Zone_Label": "Def Circle"},
    {"Location": "Defensive Right Pocket", "x": 3, "y": 1, "Zone_Label": "DR Pocket"},
    {"Location": "Defensive Left", "x": 1, "y": 2, "Zone_Label": "Def Left"},
    {"Location": "Defensive Middle", "x": 2, "y": 2, "Zone_Label": "Def Mid"},
    {"Location": "Defensive Right", "x": 3, "y": 2, "Zone_Label": "Def Right"},
    {"Location": "Center Left Defense", "x": 1, "y": 3, "Zone_Label": "C Left (D)"},
    {"Location": "Center Mid Defense", "x": 2, "y": 3, "Zone_Label": "C Mid (D)"},
    {"Location": "Center Right Defense", "x": 3, "y": 3, "Zone_Label": "C Right (D)"},
    {"Location": "Center Left Attack", "x": 1, "y": 4, "Zone_Label": "C Left (A)"},
    {"Location": "Center Mid Attack", "x": 2, "y": 4, "Zone_Label": "C Mid (A)"},
    {"Location": "Center Right Attack", "x": 3, "y": 4, "Zone_Label": "C Right (A)"},
    {"Location": "Attacking Left", "x": 1, "y": 5, "Zone_Label": "Att Left"},
    {"Location": "Attacking Middle", "x": 2, "y": 5, "Zone_Label": "Att Mid"},
    {"Location": "Attacking Right", "x": 3, "y": 5, "Zone_Label": "Att Right"},
    {"Location": "Attacking Left Pocket", "x": 1, "y": 6, "Zone_Label": "AL Pocket"},
    {"Location": "Attacking D", "x": 2, "y": 6, "Zone_Label": "Att Circle"},
    {"Location": "Attacking Right Pocket", "x": 3, "y": 6, "Zone_Label": "AR Pocket"}
])

# ==============================================================================
# 3. HELPER FUNCTIONS
# ==============================================================================
def load_data(file):
    if file is None: return None
    df = pd.read_csv(file)
    df.columns = df.columns.str.replace('.', ' ', regex=False).str.replace(r'^X', '', regex=True)
    cols_to_check = ["Ungrouped", "Notes", "Flags"]
    existing_cols = [c for c in cols_to_check if c in df.columns]
    if existing_cols: df = df.dropna(axis=1, how='all', subset=existing_cols)
    if 'Quarter' in df.columns:
        df['Quarter'] = df['Quarter'].astype(str).str.split(',').str[0].str.strip()
    return df

def draw_court_heatmap(data, map_df, title, val_col="Count", label_col="Label", colorscale="Reds"):
    if data.empty: return go.Figure()
    merged = pd.merge(map_df, data, on="Location", how="left").fillna(0)
    fig = go.Figure()
    fig.add_trace(go.Heatmap(x=merged['x'], y=merged['y'], z=merged[val_col], colorscale=colorscale, showscale=False, xgap=2, ygap=2))
    fig.add_trace(go.Scatter(x=merged['x'], y=merged['y'], mode='text', text=merged[val_col].astype(int).astype(str), textfont=dict(size=20, color='black', family="Arial Black")))
    fig.add_trace(go.Scatter(x=merged['x'], y=merged['y'] - 0.35, mode='text', text=merged[label_col], textfont=dict(size=10, color='black')))
    fig.update_layout(title=title, xaxis=dict(showticklabels=False, showgrid=False, zeroline=False), yaxis=dict(showticklabels=False, showgrid=False, zeroline=False), plot_bgcolor='white', width=400, height=500, margin=dict(l=10, r=10, t=40, b=10))
    return fig

# ==============================================================================
# 4. MAIN APP LAYOUT
# ==============================================================================
st.sidebar.title("Configuration")
uploaded_file = st.sidebar.file_uploader("Upload Match CSV", type="csv")
if not uploaded_file:
    st.info("Upload 'mock_netball_data_streamlit.csv' to begin.")
    st.stop()

df = load_data(uploaded_file)
team_name = st.sidebar.text_input("My Team Name", "Home Team")
opp_name = st.sidebar.text_input("Opponent Name", "Away Team")
tab1, tab2, tab3, tab4 = st.tabs(["Summary", "Shooting", "Passing (CPA)", "Defense"])

# --- TAB 1: SUMMARY ---
with tab1:
    st.header("Match Summary")
    def get_score(filter_str, outcome_str):
        subset = df[df['Row'] == filter_str].copy()
        subset['Goals'] = subset['Shot Outcome'].astype(str).str.count(outcome_str)
        return subset.groupby('Quarter')['Goals'].sum().reset_index()

    home_scores = get_score("Home Shot", "Home Goal")
    away_scores = get_score("Away Shot", "Away Goal")
    col1, col2 = st.columns(2)
    col1.metric(label=f"{team_name} Score", value=int(home_scores['Goals'].sum()))
    col2.metric(label=f"{opp_name} Score", value=int(away_scores['Goals'].sum()))
    
    st.subheader("Match Momentum")
    st.info("ℹ️ **Graph Guide:** The shaded vertical bands highlight **Scoring Runs**, defined as periods where a team scores **4 or more consecutive goals**.")
    
    goal_mask = (df['Row'].astype(str).str.contains("Shot")) & (df['Shot Outcome'].astype(str).str.contains("Goal"))
    goals_df = df[goal_mask].copy()
    goals_df['Scorer'] = goals_df['Shot Outcome'].apply(lambda x: team_name if "Home Goal" in str(x) else opp_name)
    goals_df['Time'] = goals_df['Start time']
    goals_df['Home_Point'] = (goals_df['Scorer'] == team_name).astype(int)
    goals_df['Away_Point'] = (goals_df['Scorer'] == opp_name).astype(int)
    
    selected_q = st.radio("Select Quarter", ["Q1", "Q2", "Q3", "Q4"], horizontal=True)
    q_data = goals_df[goals_df['Quarter'] == selected_q].sort_values('Time').copy()
    
    if not q_data.empty:
        q_data['Home_Score'] = q_data['Home_Point'].cumsum()
        q_data['Away_Score'] = q_data['Away_Point'].cumsum()
        q_data['grp'] = (q_data['Scorer'] != q_data['Scorer'].shift()).cumsum()
        run_counts = q_data.groupby('grp')['Scorer'].transform('count')
        q_data['Is_Run'] = run_counts >= 4
        
        fig = go.Figure()
        fig.add_trace(go.Scatter(x=q_data['Time'], y=q_data['Home_Score'], mode='lines+markers', name=team_name, line=dict(color='#E03C31', width=3, shape='hv')))
        fig.add_trace(go.Scatter(x=q_data['Time'], y=q_data['Away_Score'], mode='lines+markers', name=opp_name, line=dict(color='#1D428A', width=3, shape='hv')))
        
        run_segments = q_data[q_data['Is_Run']].groupby('grp').agg(Start=('Time', 'min'), End=('Time', 'max'), Scorer=('Scorer', 'first')).reset_index()
        for _, row in run_segments.iterrows():
            fill_color = "rgba(224, 60, 49, 0.2)" if row['Scorer'] == team_name else "rgba(29, 66, 138, 0.2)"
            fig.add_vrect(x0=row['Start'], x1=row['End'], fillcolor=fill_color, opacity=1, layer="below", line_width=0, annotation_text=f"{row['Scorer']} Run", annotation_position="top left")
        
        fig.update_layout(title=f"Score Progression - {selected_q}", hovermode="x unified")
        st.plotly_chart(fig, use_container_width=True)
    else:
        st.warning("No data for this quarter.")

# --- TAB 2: SHOOTING ---
with tab2:
    st.header("Shooting Statistics")
    
    # Filter for Home Shots
    shot_df = df[df['Row'] == "Home Shot"].copy()

    # --- 1. SHOOTING TABLE ---
    # We group by Player AND Position now
    if 'Position' in shot_df.columns:
        grp_cols = ['Player', 'Position']
    else:
        grp_cols = ['Player']

    player_stats = shot_df.groupby(grp_cols).agg(
        Attempts=('Row', 'count'),
        Goals=('Shot Outcome', lambda x: x.str.contains("Goal").sum())
    ).reset_index()
    player_stats['Pct'] = (player_stats['Goals'] / player_stats['Attempts'] * 100).round(1)
    
    col_s1, col_s2 = st.columns([1, 1])
    with col_s1:
        st.subheader("Player Stats")
        st.dataframe(player_stats, hide_index=True, use_container_width=True)

    # --- 2. GOALS BY POSITION (Stacked Bar) ---
    with col_s2:
        st.subheader("Goals Breakdown")
        if 'Position' in player_stats.columns:
            fig_stack = px.bar(
                player_stats, 
                x="Position", 
                y="Goals", 
                color="Player", 
                title="Goals by Position & Player",
                text="Goals",
                color_discrete_sequence=px.colors.qualitative.Pastel
            )
            st.plotly_chart(fig_stack, use_container_width=True)
        else:
            st.warning("Position data not found. Run the R script to update your CSV.")

    # --- 3. SHOT LOCATION VISUALIZATION ---
    st.divider()
    st.subheader("Shot Location Analysis")
    
    if 'Shot Location' in shot_df.columns:
        # Prepare Data: Group by Location and Outcome
        loc_df = shot_df.copy()
        loc_df['Outcome'] = loc_df['Shot Outcome'].apply(lambda x: "Goal" if "Goal" in str(x) else "Miss")
        
        loc_stats = loc_df.groupby(['Shot Location', 'Outcome']).size().reset_index(name='Count')
        
        # Calculate accuracy for sorting/text
        accuracy = loc_df.groupby('Shot Location').apply(lambda x: (x['Shot Outcome'].str.contains("Goal").sum() / len(x)) * 100).reset_index(name='Acc')
        
        col_l1, col_l2 = st.columns(2)
        
        with col_l1:
            # Bar Chart: Volume by Zone
            fig_loc = px.bar(
                loc_stats, 
                x="Shot Location", 
                y="Count", 
                color="Outcome", 
                title="Shot Volume by Zone",
                barmode='group',
                color_discrete_map={"Goal": "#57BB8A", "Miss": "#E67C73"},
                category_orders={"Shot Location": ["Inner Circle", "Outer Circle", "Circle Edge"]}
            )
            st.plotly_chart(fig_loc, use_container_width=True)
            
        with col_l2:
            # Gauge or Simple Bar for Accuracy
            fig_acc = px.bar(
                accuracy, 
                x="Shot Location", 
                y="Acc", 
                title="Accuracy % by Zone",
                text="Acc",
                color="Acc",
                color_continuous_scale="RdYlGn",
                category_orders={"Shot Location": ["Inner Circle", "Outer Circle", "Circle Edge"]}
            )
            fig_acc.update_traces(texttemplate='%{text:.1f}%', textposition='outside')
            fig_acc.update_layout(yaxis_title="Accuracy %", yaxis_range=[0, 110])
            st.plotly_chart(fig_acc, use_container_width=True)
    else:
        st.warning("Column 'Shot Location' not found. Please regenerate data using the R script.")

# --- TAB 3: CPA ---
with tab3:
    st.header("Centre Pass Attack (CPA)")
    def calc_cpa_stats(row_filter, goal_key, label_type):
        subset = df[df['Row'] == row_filter].copy()
        if subset.empty: return pd.DataFrame()
        stats = subset.groupby('Quarter').agg(Poss=('Row', 'count'), Goals=('Shot Outcome', lambda x: x.str.contains(goal_key).sum())).reset_index()
        stats['Type'] = label_type
        stats['Conv'] = (stats['Goals'] / stats['Poss'] * 100).round(1)
        return stats

    cpa_stats = calc_cpa_stats("Home CPA", "Home Goal", "CPA")
    dcpa_stats = calc_cpa_stats("Home DCPA", "Home Goal", "DCPA")
    combined_cpa = pd.concat([cpa_stats, dcpa_stats])
    if not combined_cpa.empty:
        fig_cpa = px.bar(combined_cpa, x="Quarter", y="Conv", color="Type", barmode="group", title="Conversion Rate (%)", text="Conv")
        st.plotly_chart(fig_cpa, use_container_width=True)
    
    st.subheader("Pass Heatmaps & Flow")
    pass1_col = next((c for c in df.columns if "1st" in c and "Pass" in c), None)
    pass2_col = next((c for c in df.columns if "2nd" in c and "Pass" in c), None)
    col_h1, col_h2 = st.columns(2)
    
    if pass1_col:
        p1 = df[df['Row'] == "Home CPA"][pass1_col].str.split(', ').explode().str.strip().value_counts().reset_index()
        p1.columns = ['Location', 'Count']
        col_h1.plotly_chart(draw_court_heatmap(p1, map_phase1, "Phase 1 (1st Pass)"), use_container_width=True)
    if pass2_col:
        p2 = df[df['Row'] == "Home CPA"][pass2_col].str.split(', ').explode().str.strip().value_counts().reset_index()
        p2.columns = ['Location', 'Count']
        col_h2.plotly_chart(draw_court_heatmap(p2, map_phase2, "Phase 2 (2nd Pass)"), use_container_width=True)

# --- TAB 4: DEFENSE ---
with tab4:
    st.header("Defense (Gains & Turnovers)")
    st.subheader("Where do we win/lose the ball?")
    loc_col = next((c for c in df.columns if "Turnover Location" in c), None)
    if loc_col:
        gains = df[df['Row'] == "Home Gains"][loc_col].str.split(', ').explode().str.strip().value_counts().reset_index()
        gains.columns = ['Location', 'Count']
        tos = df[df['Row'] == "Home Turnovers"][loc_col].str.split(', ').explode().str.strip().value_counts().reset_index()
        tos.columns = ['Location', 'Count']
        col_d1, col_d2 = st.columns(2)
        col_d1.plotly_chart(draw_court_heatmap(gains, court_map_gnto, "Gains", colorscale="Greens", label_col="Zone_Label"), use_container_width=True)
        col_d2.plotly_chart(draw_court_heatmap(tos, court_map_gnto, "Turnovers", colorscale="Reds", label_col="Zone_Label"), use_container_width=True)

    reason_col = next((c for c in df.columns if "Reason" in c), None)
    if reason_col:
        reasons = df[df['Row'].isin(["Home Gains", "Home Turnovers"])].copy()
        reasons_counts = reasons.groupby(['Row', reason_col]).size().reset_index(name='Count')
        fig_reason = px.bar(reasons_counts, x="Count", y=reason_col, color="Row", barmode="group", color_discrete_map={"Home Gains": "#57BB8A", "Home Turnovers": "#E67C73"}, orientation='h', title="Reasons Breakdown")
        st.plotly_chart(fig_reason, use_container_width=True)

# End of dashboard.py        
