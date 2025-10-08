class Api::V1::GamesController < ApplicationController
  before_action :set_game, only: [:show, :update, :destroy, :pick_card, :submit_form]

  # GET /api/v1/games
  def index
    @games = Game.includes(:player, :cards).order(created_at: :desc)
    
    games_data = @games.map do |game|
      {
        id: game.id,
        token: game.token,
        played: game.played?,
        form_submitted: game.form_submitted?,
        played_at: game.played_at,
        form_submitted_at: game.form_submitted_at,
        created_at: game.created_at,
        won_prize: game.won_prize&.name,
        player_picked_card: game.player&.picked_card,
        card_distribution: game.cards.ordered_by_position.map do |card|
          {
            position: card.position,
            prize: card.prize.name
          }
        end
      }
    end
    
    render json: {
      games: games_data,
      total: @games.count,
      played_games: @games.where(played: true).count,
      unplayed_games: @games.where(played: false).count
    }
  end

  # GET /api/v1/games/:token
  def show
    @game = Game.includes(:player, :cards).find_by!(token: params[:token])
    
    game_data = {
      id: @game.id,
      token: @game.token,
      played: @game.played?,
      form_submitted: @game.form_submitted?,
      played_at: @game.played_at,
      form_submitted_at: @game.form_submitted_at,
      created_at: @game.created_at,
      won_prize: @game.won_prize&.name,
      player_picked_card: @game.player&.picked_card,
      card_distribution: @game.cards.ordered_by_position.map do |card|
        {
          position: card.position,
          prize: card.prize.name
        }
      end
    }
    
    render json: game_data
  end

  # POST /api/v1/games
  def create
    begin
      @game = GameCreationService.create_game!
      
      render json: {
        id: @game.id,
        token: @game.token,
        played: @game.played?,
        form_submitted: @game.form_submitted?,
        created_at: @game.created_at,
        card_distribution: @game.cards.ordered_by_position.map do |card|
          {
            position: card.position,
            prize: card.prize.name
          }
        end
      }, status: :created
    rescue => e
      render json: { 
        error: "Failed to create game: #{e.message}" 
      }, status: :unprocessable_entity
    end
  end

  # POST /api/v1/games/:token/pick_card
  def pick_card
    # Validate game can be played
    if @game.played?
      render json: { 
        error: "Game has already been played",
        code: "GAME_ALREADY_PLAYED"
      }, status: :unprocessable_entity
      return
    end

    # Validate card position
    card_position = params[:card_position].to_i
    if card_position < 1 || card_position > 10
      render json: { 
        error: "Invalid card position. Must be between 1 and 10",
        code: "INVALID_CARD_POSITION"
      }, status: :unprocessable_entity
      return
    end

    begin
      # Mark game as played and create player record
      @game.mark_as_played!(card_position)
      
      # Reload the game with associations
      @game.reload
      
      # Build response with all cards revealed
      game_data = {
        success: true,
        game: {
          id: @game.id,
          token: @game.token,
          played: @game.played?,
          form_submitted: @game.form_submitted?,
          played_at: @game.played_at,
          form_submitted_at: @game.form_submitted_at,
          created_at: @game.created_at,
          won_prize: @game.won_prize&.name,
          player_picked_card: @game.player&.picked_card,
          card_distribution: @game.cards.ordered_by_position.map do |card|
            {
              position: card.position,
              prize: card.prize.name,
              revealed: true,
              picked: card.position == card_position
            }
          end
        }
      }
      
      render json: game_data
    rescue => e
      render json: { 
        error: "Failed to pick card: #{e.message}",
        code: "PICK_CARD_FAILED"
      }, status: :unprocessable_entity
    end
  end

  # POST /api/v1/games/:token/submit_form
  def submit_form
    # Validate game has been played
    unless @game.played?
      render json: { 
        error: "Game must be played before submitting form",
        code: "GAME_NOT_PLAYED"
      }, status: :unprocessable_entity
      return
    end

    # Validate form hasn't been submitted already
    if @game.form_submitted?
      render json: { 
        error: "Form has already been submitted",
        code: "FORM_ALREADY_SUBMITTED"
      }, status: :unprocessable_entity
      return
    end

    # Validate player exists
    unless @game.player
      render json: { 
        error: "Player record not found",
        code: "PLAYER_NOT_FOUND"
      }, status: :unprocessable_entity
      return
    end

    begin
      # Create prize submission
      prize_submission = @game.player.create_prize_submission!(
        first_name: params[:first_name],
        last_name: params[:last_name],
        email: params[:email],
        address1: params[:address1],
        address2: params[:address2],
        city: params[:city],
        state: params[:state],
        country: params[:country],
        zip: params[:zip]
      )

      # Mark game form as submitted
      @game.mark_form_submitted!

      render json: {
        success: true,
        message: "Prize form submitted successfully!",
        submission: {
          id: prize_submission.id,
          full_name: prize_submission.full_name,
          email: prize_submission.email,
          full_address: prize_submission.full_address,
          submitted_at: prize_submission.created_at
        },
        game: {
          id: @game.id,
          token: @game.token,
          played: @game.played?,
          form_submitted: @game.form_submitted?,
          won_prize: @game.won_prize&.name,
          player_picked_card: @game.player&.picked_card
        }
      }
    rescue ActiveRecord::RecordInvalid => e
      render json: { 
        error: "Validation failed: #{e.message}",
        code: "VALIDATION_ERROR",
        details: e.record.errors.full_messages
      }, status: :unprocessable_entity
    rescue => e
      render json: { 
        error: "Failed to submit form: #{e.message}",
        code: "SUBMIT_FORM_FAILED"
      }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/games/:token
  def update
    if @game.update(game_params)
      render json: @game
    else
      render json: @game.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/games/:token
  def destroy
    @game.destroy
    head :no_content
  end

  private

  def set_game
    @game = Game.find_by!(token: params[:token])
  end

  def game_params
    params.require(:game).permit(:played, :form_submitted)
  end
end